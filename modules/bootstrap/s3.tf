// S3 Bucket for backend states
resource "aws_s3_bucket" "infrastructure_states_bucket" {
  bucket = var.infrastructure_states_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "infrastructure_states_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.infrastructure_states_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "infrastructure_states_bucket_versioning" {
  bucket = aws_s3_bucket.infrastructure_states_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

// S3 Bucket for required Terraform assets
resource "aws_s3_bucket" "infrastructure_assets_bucket" {
  bucket = var.infrastructure_assets_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "infrastructure_assets_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.infrastructure_assets_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// S3 Bucket for CodeBuild artifacts
resource "aws_s3_bucket" "infrastructure_artifacts_bucket" {
  bucket = var.infrastructure_artifacts_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "infrastructure_artifacts_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.infrastructure_artifacts_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
