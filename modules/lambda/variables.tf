variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "function_name" {
  description = "DynamoDB function name"
  type        = string
}

variable "package" {
  description = "Path to Lambda deployment package"
  type        = string
}

variable "package_hash" {
  description = "Base64-encoded SHA256 hash of the Lambda deployment package"
  type        = string
  default     = null
}

variable "prefix" {
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
  
}
