variable "allowed_account_ids" {
  default     = []
  description = "Optional list of AWS Account IDs that are permitted to write to the bucket"
  type        = list(string)
}

variable "bucket_name" {
  default     = null
  description = "Name of the S3 bucket to create. Defaults to {account_id}-{region}-cloudtrail."
  type        = string
}

variable "lifecycle_rules" {
  description = "lifecycle rules to apply to the bucket"

  default = [
    {
      id                            = "expire-noncurrent-objects-after-ninety-days"
      noncurrent_version_expiration = 90
    },
    {
      id = "transition-to-IA-after-30-days"
      transition = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }]
    },
    {
      id         = "delete-after-seven-years"
      expiration = 2557
    },
  ]

  type = list(object(
    {
      id                            = string
      enabled                       = optional(bool, true)
      expiration                    = optional(number)
      prefix                        = optional(number)
      noncurrent_version_expiration = optional(number)
      transition = optional(list(object({
        days          = number
        storage_class = string
      })))
  }))
}

variable "logging_bucket" {
  default     = "cloudtrail-accesslogs-535346532466"
  description = "S3 bucket with suitable access for logging requests to the cloudtrail bucket"
  type        = string
}

variable "versioning_enabled" {
  default     = true
  description = "Whether or not to use versioning on the bucket. This can be useful for audit purposes since objects in a logging bucket should not be updated."
  type        = bool
}

variable "cloudtrail_name" {
  default     = "cloudtrail-all"
  description = "Name for the CloudTrail"
  type        = string
}

variable "iam_path" {
  default     = "/"
  description = "Path under which to put the IAM role. Should begin and end with a '/'."
  type        = string
}

variable "lambda_functions" {
  default     = []
  description = "Lambda functions to log. Specify `[\"arn:aws:lambda\"]` for all, or `[ ]` for none."
  type        = list(any)
}

variable "log_group_name" {
  default     = "cloudtrail2cwl"
  description = "Name for CloudTrail log group"
  type        = string
}

variable "region" {
  default     = "us-east-1"
  description = "Region that CloudWatch logging and the S3 bucket will live in"
  type        = string
}

variable "retention_in_days" {
  default     = 7
  description = "How long should CloudTrail logs be retained in CloudWatch (does not affect S3 storage). Set to -1 for indefinite storage."
  type        = number
}

variable "tags" {
  default     = {}
  description = "Mapping of any extra tags you want added to resources"
  type        = map(string)
}

variable "s3_object_level_buckets" {
  default     = []
  description = "ARNs of buckets for which to enable object level logging. Specify `[\"arn:aws:s3:::\"]` for all, or `[ ]` for none. If listing ARNs, make sure to end each one with a `/`."
  type        = list(any)
}