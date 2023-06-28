resource "aws_codebuild_project" "infrastructure_terraform_plan_project" {
  lifecycle { ignore_changes = [project_visibility] }

  name          = var.infrastructure_terraform_plan_project_name
  description   = "Infrastructure Terraform Plan Project"
  build_timeout = "5"
  service_role  = aws_iam_role.infrastructure_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ASSETS_BUCKET_NAME"
      value = var.infrastructure_assets_bucket_name
    }

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.infrastructure_terraform_version
    }

    environment_variable {
      name  = "AWS_PROVIDER_VERSION"
      value = var.infrastructure_terraform_aws_provider_version
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.infrastructure_terraform_plan_project_name}-logs"
      stream_name = var.infrastructure_terraform_plan_project_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_plan.yml"
  }
}

resource "aws_codebuild_project" "infrastructure_terraform_apply_project" {
  lifecycle { ignore_changes = [project_visibility] }

  name          = var.infrastructure_terraform_apply_project_name
  description   = "Infrastructure Terraform Apply Project"
  build_timeout = "5"
  service_role  = aws_iam_role.infrastructure_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ASSETS_BUCKET_NAME"
      value = var.infrastructure_assets_bucket_name
    }

    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.infrastructure_terraform_version
    }

    environment_variable {
      name  = "AWS_PROVIDER_VERSION"
      value = var.infrastructure_terraform_aws_provider_version
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.infrastructure_terraform_apply_project_name}-logs"
      stream_name = var.infrastructure_terraform_apply_project_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_apply.yml"
  }
}
