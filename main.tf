terraform {
  required_version = ">=1.4.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.24.0"
    }
  }

  /*
  backend "s3" {
    bucket         = "infrastructure-states"
    key            = "infrastructure.state"
    region         = "cn-northwest-1"
    dynamodb_table = "infrastructure-locks"
    encrypt        = true
  }
  */
}

provider "aws" {
  region = "cn-northwest-1"

  /*
  assume_role {
    role_arn = "arn:aws-cn:iam::001122334455:role/infrastructure-terraform-role"
  }
  */
}

module "bootstrap" {
  source = "./modules/bootstrap"

  // Terraform backend configuration
  infrastructure_states_bucket_name = "infrastructure-states"
  infrastructure_locks_table_name   = "infrastructure-locks"

  // Bucket names
  infrastructure_assets_bucket_name    = "infrastructure-assets"
  infrastructure_artifacts_bucket_name = "infrastructure-artifacts"

  // CodeCommit repository name
  infrastructure_repository_name = "infrastructure-repository"

  // CodeBuild project names
  infrastructure_terraform_plan_project_name  = "terraform-plan"
  infrastructure_terraform_apply_project_name = "terraform-apply"

  // Terraform CodeBuild configuration
  infrastructure_terraform_version              = "1.4.4"
  infrastructure_terraform_aws_provider_version = "4.24.0"

  // CodePipeline configuration
  infrastructure_pipeline_name = "infrastructure-pipeline"
}

module "infrastructure" {
  source = "./modules/infrastructure"
}
