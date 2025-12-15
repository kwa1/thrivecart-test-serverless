variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "production", "dev"], var.env)
    error_message = "Environment must be one of: staging, production, dev."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}
variable "prefix" {
  type    = string
  default = "thrivecart"

}

variable "lambda_package_hash" {
  description = "Base64-encoded SHA256 hash of the Lambda deployment package"
  type        = string
  default     = null
}
