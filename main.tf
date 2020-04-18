provider "aws" {
  version = "~> 2.0"
  region = var.aws_region
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  lifecycle_rule {
    id      = "expiration"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 395
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = join("", [var.function_name, "_role"])
  path = "/service-role/"

  assume_role_policy = templatefile("assume-role-policy.tmpl", {})
}

resource "aws_lambda_function" "backup_lambda" {
  filename      = "payload.zip"
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  timeout       = 60

  source_code_hash = filebase64sha256("payload.zip")

  runtime = "nodejs12.x"

  environment {
    variables = {
      S3_BUCKET = var.bucket_name,
      MONGO_CLUSTER_SHARD = var.mongo_cluster_shard,
      MONGO_DB_NAME = var.mongo_db_name,
      MONGO_PW = var.mongo_pw,
      MONGO_REPLICA_SET = var.mongo_replica_set,
      MONGO_USER = var.mongo_user,
    }
  }
}

resource "aws_iam_policy" "execution_role_policy" {
  name        = join("", [var.function_name, "_policy"])
  path        = "/"

  policy = templatefile("lambda-execution-role-policy.tmpl", { aws_region = var.aws_region, aws_account_id = var.aws_account_id, bucket_name = var.bucket_name})
}

resource "aws_iam_policy" "bucket_management_policy" {
  name        = join("", [var.bucket_name, "_management_policy"])
  path        = "/"

  policy = templatefile("bucket-management-policy.tmpl", { bucket_name = var.bucket_name})
}

resource "aws_iam_role_policy_attachment" "execution_role_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.execution_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "bucket_management_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.bucket_management_policy.arn
}


resource "aws_cloudwatch_event_rule" "backup" {
  name        = "hymnal-backup"
  description = "Triggers a regular backup for the Hooligan Hymnal database"

  schedule_expression = "rate(7 days)"
}

resource "aws_cloudwatch_event_target" "backup_database" {
  rule      = aws_cloudwatch_event_rule.backup.name
  arn       = aws_lambda_function.backup_lambda.arn
}