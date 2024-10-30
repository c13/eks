resource "aws_cloudtrail" "trail" {
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch_events_role.arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cwl_loggroup.arn}:*"
  enable_log_file_validation = "true"
  enable_logging             = "true"
  is_multi_region_trail      = "true"
  name                       = var.cloudtrail_name
  s3_bucket_name             = local.bucket_name
  tags                       = var.tags

  # S3 object logging:
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    dynamic "data_resource" {
      for_each = local.log_s3
      content {
        type   = "AWS::S3::Object"
        values = var.s3_object_level_buckets
      }
    }

    dynamic "data_resource" {
      for_each = local.log_lambda
      content {
        type   = "AWS::Lambda::Function"
        values = var.lambda_functions
      }
    }
  }
  depends_on = [aws_s3_bucket.this]
}

resource "aws_iam_role" "cloudtrail_cloudwatch_events_role" {
  name_prefix        = "cloudtrail_events_role"
  path               = var.iam_path
  assume_role_policy = data.aws_iam_policy_document.cwl_assume_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "cwl_policy" {
  name_prefix = "cloudtrail_cloudwatch_events_policy"
  role        = aws_iam_role.cloudtrail_cloudwatch_events_role.id
  policy      = data.aws_iam_policy_document.cwl_policy.json
}

resource "aws_cloudwatch_log_group" "cwl_loggroup" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days == -1 ? null : var.retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "cwl_stream" {
  name           = local.account_id
  log_group_name = aws_cloudwatch_log_group.cwl_loggroup.name
}