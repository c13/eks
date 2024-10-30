locals {
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = var.bucket_name == null ? "${local.account_id}-${var.region}-cloudtrail" : var.bucket_name
  partition   = data.aws_partition.current.partition

  # Account IDs that will have access to stream CloudTrail logs
  account_ids = concat([local.account_id], var.allowed_account_ids)

  # Format account IDs into necessary resource lists.
  bucket_policy_put_resources = formatlist("${aws_s3_bucket.this.arn}/AWSLogs/%s/*", local.account_ids)

  # Need a list to work with for_each, but don't actually want to for_each
  log_s3     = length(var.s3_object_level_buckets) > 0 ? [true] : []
  log_lambda = length(var.lambda_functions) > 0 ? [true] : []
}