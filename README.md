# AWS China Terraform Deployment Pipeline
This repository contains all the code and information to successfully create a pipeline to automatically deploy infrastructure via Terraform scripts on AWS China.

## Created Resources
By going through all the described steps, the following resources will be created within your AWS China account:
- **S3 Buckets:**
  - **States Bucket:** Contains the Terraform states. SSE-S3 encryption is enabled. Versioning is enabled which allows accessing previous states.
  - **Assets Bucket:** Will be used to store assets used by Terraform since we have difficulties in China to directly download the latest versions of Terraform and the required AWS Provider via the public internet from the official HashiCorp servers. SSE-S3 encryption is enabled.
  - **Artifacts Bucket:** Contains the artifacts generated by CodeBuild. SSE-S3 encryption is enabled.
- **DynamoDB Locks Table:** Contains the Terraform lock states.
- **IAM Policy:** A general IAM policy with full permissions used for all infrastructure operations.
- **IAM Roles:**
  - **Terraform Role:** Assumed by Terraform to deploy the infrastructure.
  - **CodeBuild Role:** Assumed by CodeBuild to operate successfully.
  - **CodePipeline Role:** Assumed by CodePipeline to operate successfully.
- **CodeCommit Repository:** Will be used to store this repositories code and all future code used for the infrastructure. The CodePipeline will pull the latest Terraform scripts from this repository.
- **CodeBuild Projects:**
  - **Terraform Plan Project:** Validates and plans the infrastructure based on the latest version within the CodeCommit repository. Linux Environment. Using ```aws/codebuild/standard:2.0``` Image. Using 3 GB memory, 2 vCPUs.
  - **Terraform Apply Project:** Applies the infrastructure based on the latest version within the CodeCommit repository. Linux Environment. Using ```aws/codebuild/standard:2.0``` Image. Using 3 GB memory, 2 vCPUs.
- **CodePipeline:** Orchestrates the entire deployment process and consists of the following four phases:
  - **get-source:** Loads the updated source from CodeCommit
  - **terraform-plan:** Validates and plans the infrastructure
  - **manual-approval:** Waits for manual approval before deploying the infrastructure
  - **terraform-apply:** Deploys the infrastructure
- **VPC:** An example VPC to demonstrate the working Terraform deployment pipeline.

## Preparations
In order to successfully create the pipeline and all required components via the in this repository provided Terraform scripts, a few preparations are necessary.

- Install [Terraform](https://developer.hashicorp.com/terraform/downloads) on your local machine (v1.4.4 or higher).
- An [AWS China](https://www.amazonaws.cn/) account (Your AWS International account will **not** work since AWS China is using a completely independent infrastructure).
- An IAM User with sufficient permissions (for example the ```AdministratorAccess``` policy) to create the pipeline and all required components during the initial bootstrapping phase.

## Detailed Instructions
In order to get the full deployment pipeline up and running, you have to perform the following steps.

### Step 1 - Clone Repository
Clone this repository into your local development environment.

### Step 2 - Adjust Variables
Adjust the variables in the ```main.tf``` file. In the ```provider``` block you can set the region to your preferred AWS China Region (possible values are ```cn-northwest-1``` and ```cn-north-1```):
```hcl
region = "cn-northwest-1"
```
Change the variables within the ```bootstrap``` module as necessary. Ensure that some names must be globally unique within AWS China (for example the S3 Bucket names).
```hcl
infrastructure_states_bucket_name             = "infrastructure-states"
infrastructure_locks_table_name               = "infrastructure-locks"
infrastructure_assets_bucket_name             = "infrastructure-assets"
infrastructure_artifacts_bucket_name          = "infrastructure-artifacts"
infrastructure_repository_name                = "infrastructure-repository"
infrastructure_terraform_plan_project_name    = "terraform-plan"
infrastructure_terraform_apply_project_name   = "terraform-apply"
infrastructure_terraform_version              = "1.4.4"
infrastructure_terraform_aws_provider_version = "4.24.0"
infrastructure_pipeline_name                  = "infrastructure-pipeline"
```

### Step 3 - Initialize Terraform
Run the following command within the folder which contains the files of this cloned repository:
```bash
terraform init
```

### Step 4 - Lock linux_amd64 Platform
Since the entire deployment process will run inside a Linux environment, ensure that you lock the ```linux_amd64``` platform within your Terraform lock file by running the following command:
```bash
terraform providers lock -platform=linux_amd64
```
Otherwise, Terraform will be not able to initialize if you are using another platform like Windows locally.

### Step 5 - Initial Deployment
Perform the initial deployment of the entire pipeline into AWS China by running the following commands and confirm the final action with a ```yes```:
```bash
terraform plan
terraform apply
```

### Step 6 - Update Terraform Backend Configuration
Now that the S3 Bucket and the DynamoDB table for the Terraform backend got successfully deployed into your AWS China account, it is time to update the Terraform configuration. Uncomment the following lines inside the ```main.tf``` file:
```hcl
backend "s3" {
  bucket         = "infrastructure-states"
  key            = "infrastructure.state"
  region         = "cn-northwest-1"
  dynamodb_table = "infrastructure-locks"
  encrypt        = true
}
```
Ensure that the values for ```bucket```, ```region``` and ```dynamodb_table``` are matching the resources and region which got defined before in *Step 2*. 

### Step 7 - Migrate the Backend
Run again the following command to migrate the existing local state into your S3 backend and confirm the action with a ```yes```:
```bash
terraform init
```

### Step 8 - Download Necessary Assets
One of the big problems within AWS China are connectivity issues to everything hosted outside of China. It is very likely that Terraform will have difficulties to directly download the latest versions of Terraform and the required AWS Provider via the public internet from the official HashiCorp servers while trying to perform operations during a CodeBuild project. To avoid this, we will download the required assets in advance and upload them to the assets bucket which got deployed into your AWS China account during *Step 5* afterwards.

Ensure that the downloaded versions are for the ```linux_amd64``` platform and matching the versions which you defined in *Step 2* inside of the ```infrastructure_terraform_version``` and ```infrastructure_terraform_aws_provider_version``` variables.

You can download the required assets from here:
- **Terraform:** https://releases.hashicorp.com/terraform/1.4.4/terraform_1.4.4_linux_amd64.zip
- **Terraform AWS Provider**: https://releases.hashicorp.com/terraform-provider-aws/4.24.0/terraform-provider-aws_4.24.0_linux_amd64.zip

**Important:** Again, ensure that you use the correct version and platform!

### Step 9 - Upload Assets to S3
After downloading the assets, you have to upload them to the assets bucket which got deployed into your AWS China account during *Step 5*. The location of the asset must follow a specific schema, for example:

- **Terraform:**
  - **File Name:** terraform_1.4.4_linux_amd64.zip
  - **Bucket Location:** s3://infrastructure-assets/terraform/1.4.4/terraform_1.4.4_linux_amd64.zip
- **Terraform AWS Provider:**
  - **File Name:** terraform-provider-aws_4.24.0_linux_amd64.zip
  - **Bucket Location:** s3://infrastructure-assets/providers/registry.terraform.io/hashicorp/aws/terraform-provider-aws_4.24.0_linux_amd64.zip

Again, ensure that the versions are consistent with the values used during *Step 2* and *Step 8*.

### Step 10 - IAM Role for Provider
We are almost done! One final modification is the adjustment of the AWS Provider configuration to ensure that Terraform is assuming an IAM role with sufficient permissions while deploying the infrastructure during a CodeBuild project. Uncomment the following lines inside the ```main.tf``` file and ensure that you are replacing ```001122334455``` with the Account ID of your AWS China account:
```hcl
assume_role {
  role_arn = "arn:aws-cn:iam::001122334455:role/infrastructure-terraform-role"
}
```

### Step 11 - Upload Code into CodeCommit
Now it is time to upload all of your code into your CodeCommit repository. Initialize and configure a new local Git repository and commit and push your code into the repository afterwards using the commands below. Ensure that you are using the ```main``` branch and the correct ```origin``` based on your defined repository name during *Step 2*.
```bash 
git init --initial-branch=main
git config credential.UseHttpPath true
git remote add origin https://git-codecommit.cn-northwest-1.amazonaws.com.cn/v1/repos/infrastructure-repository
git add .
git commit -m "Initial commit"
git push --set-upstream origin main
```

### Step 12 - Verify
And that's it! Your AWS China Terraform Deployment Pipeline should now work properly. To verify that everything is working, log into your AWS China Management Console, switch to CodePipeline service and check the current status. If everything goes well, then your CodePipeline will transition to the ```manual-approval``` stage after a while. Since we didn't apply any further changes to the infrastructure since the last deployment from the local machine so far, everything should be up to date. So just go ahead and approve the current stage to move into the final ```terraform-apply``` stage which finishes the execution.

### Step 13 - (Optional) Add Your Own Infrastructure
Now it is time to add your own infrastructure! I created an additional module called ```infrastructure``` in which you can place your custom resources. Inside the ```/modules/infrastructure/vpc.tf``` file you can find the definition for an example VPC which you can uncomment. If you commit and push the changes into your repository, the pipeline will detect the modifications, verifies them and applies them after a manual approval.

Feel free to play around with your own resources or add additional modules to build a more complex infrastructure!