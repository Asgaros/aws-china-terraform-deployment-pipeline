resource "aws_codepipeline" "infrastructure_pipeline" {
  name     = var.infrastructure_pipeline_name
  role_arn = aws_iam_role.infrastructure_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.infrastructure_artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "get-source"

    action {
      name             = "get-source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName = var.infrastructure_repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = var.infrastructure_terraform_plan_project_name

    action {
      name            = var.infrastructure_terraform_plan_project_name
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName = var.infrastructure_terraform_plan_project_name
      }
    }
  }

  stage {
    name = "manual-approval"

    action {
      name     = "approve-infrastructure"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = var.infrastructure_terraform_apply_project_name

    action {
      name            = var.infrastructure_terraform_apply_project_name
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName = var.infrastructure_terraform_apply_project_name
      }
    }
  }
}
