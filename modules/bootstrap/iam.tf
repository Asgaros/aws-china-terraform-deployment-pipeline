// A general IAM policy with full permissions used for all infrastructure operations
resource "aws_iam_policy" "infrastructure_policy" {
  name = "infrastructure-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

// Terraform will assume this IAM role to deploy the infrastructure during a CodeBuild project
resource "aws_iam_role" "infrastructure_terraform_role" {
  name = "infrastructure-terraform-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.infrastructure_codebuild_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "infrastructure_terraform_role_policy_attachment" {
  role       = aws_iam_role.infrastructure_terraform_role.name
  policy_arn = aws_iam_policy.infrastructure_policy.arn
}

// CodePipeline will assume this IAM role
resource "aws_iam_role" "infrastructure_codepipeline_role" {
  name = "infrastructure-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "infrastructure_codepipeline_role_policy_attachment" {
  role       = aws_iam_role.infrastructure_codepipeline_role.name
  policy_arn = aws_iam_policy.infrastructure_policy.arn
}

// CodeBuild will assume this IAM role
resource "aws_iam_role" "infrastructure_codebuild_role" {
  name = "infrastructure-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "infrastructure_codebuild_role_policy_attachment" {
  role       = aws_iam_role.infrastructure_codebuild_role.name
  policy_arn = aws_iam_policy.infrastructure_policy.arn
}
