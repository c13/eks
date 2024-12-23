## NOTE: It's going to use your AWS_REGION or AWS_DEFAULT_REGION environment variable,
## but you can define which on to use in terraform.tfvars file as well, or pass it as an argument
## in the CLI like this "terraform apply -var 'region=eu-west-1'"
variable "region" {
  description = "Region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "docker_secret" {
  description = "Docker username and accessToken to allow pullTroughCache to get images from Docker.io. E.g. `{username='user',accessToken='pass'}`"
  type = object({
    username    = string
    accessToken = string
  })
  sensitive = true
}

variable "dns_zone" {
  description = "DNS zone to create records"
  type        = string
}

variable "capacity_type" {
  description = "Capacity type for EKS managed node group"
  type        = string
  default     = "ON-DEMAND"
}