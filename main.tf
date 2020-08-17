# Full CodePipeline
resource "aws_codepipeline" "default" {
  name     = "${var.name}-Pipeline-${random_string.random_pipeline.result}"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store = {
    location = "${aws_s3_bucket.artifact_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn        = "${var.connection_arn}"
        FullRepositoryId     = "${var.respository_id}"
        BranchName           = "${var.branch_name}"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.codebuild.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      configuration {
        BucketName = "${var.s3_bucket_hosting_name}"
        Extract    = "true"
      }

      input_artifacts = ["build"]
    }
  }

  tags = "${merge(var.tags, map(
    "Name", "${var.name}-Pipeline-${random_string.random_pipeline.result}"
  ))}"
}

resource "aws_codebuild_project" "codebuild" {
  name          = "${var.name}-Build-${random_string.random_pipeline.result}"
  description   = ""
  service_role  = "${aws_iam_role.codebuild_role.arn}"
  build_timeout = "5"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = "false"

    environment_variable {
      name  = "HOSTING_S3_BUCKET_NAME"
      value = "${var.s3_bucket_hosting_name}"
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = "${var.environment}"
    }

    environment_variable {
      name  = "ARTIFACT_S3_BUCKET_NAME"
      value = "${aws_s3_bucket.artifact_bucket.id}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${var.buildspec}"
  }

  tags = "${merge(var.tags, map(
    "Name", "${var.name}-Build-${random_string.random_pipeline.result}"
  ))}"
}

############################################33
#CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.name}-CodeBuild-Role-${random_string.random_pipeline.result}"

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

  tags = "${merge(var.tags, map(
    "Name", "${var.name}-CodeBuild-Role-${random_string.random_pipeline.result}"
  ))}"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.name}-CodepiPeline-Role-${random_string.random_pipeline.result}"

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

  tags = "${merge(var.tags, map(
    "Name", "${var.name}-CodeBuild-Role-${random_string.random_pipeline.result}"
  ))}"
}

##########################################
#Permissions

resource "aws_iam_role_policy_attachment" "policy_attachment_pipeline_deploy" {
  role       = "${aws_iam_role.codepipeline_role.name}"
  policy_arn = "${aws_iam_policy.deploy_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_build_deploy" {
  role       = "${aws_iam_role.codebuild_role.name}"
  policy_arn = "${aws_iam_policy.deploy_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_pipeline" {
  role       = "${aws_iam_role.codepipeline_role.name}"
  policy_arn = "${aws_iam_policy.pipeline_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_build" {
  role       = "${aws_iam_role.codebuild_role.name}"
  policy_arn = "${aws_iam_policy.pipeline_policy.arn}"
}

resource "aws_iam_policy" "deploy_policy" {
  name        = "${var.name}-Pipeline-Deploy-Policy-${random_string.random_pipeline.result}"
  path        = "/"
  description = "Deploy policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutBucketAcl",
                "s3:PutBucketPolicy",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:DeleteBucketPolicy",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::*/*",
                "${var.s3_bucket_hosting_arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "pipeline_policy" {
  name        = "${var.name}-Pipeline-Policy-${random_string.random_pipeline.result}"
  path        = "/"
  description = "Pipeline Generic"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "codestar-connections:*",
                "codebuild:StartBuild",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "codebuild:BatchGetBuilds",
                "cloudwatch:*"
                
               
            ],
            "Resource": "*"
        },
        
         {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.artifact_bucket.arn}/*"
        }
    ]
}
EOF
}

###############################################################
#Bucket - Artifacts CodePipeline
resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${lower(var.name)}-bucket-artifact-${random_string.random_artifact_bucket.result}"
  acl           = "private"
  force_destroy = "false"
}

resource "aws_s3_bucket_policy" "artifact_bucket_policy" {
  bucket = "${aws_s3_bucket.artifact_bucket.id}"

  policy = "${data.aws_iam_policy_document.artifact_bucket_policy_document.json}"
}

data "aws_iam_policy_document" "artifact_bucket_policy_document" {
  statement {
    sid       = "1"
    actions   = ["*"]
    resources = ["${aws_s3_bucket.artifact_bucket.arn}/*"]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.codebuild_role.arn}"]
    }
  }
}

resource "random_string" "random_artifact_bucket" {
  length    = 6
  min_lower = 6
  special   = false
}

resource "random_string" "random_pipeline" {
  length    = 6
  min_lower = 6
  special   = false
}
