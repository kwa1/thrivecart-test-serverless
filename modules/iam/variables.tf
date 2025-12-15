variable "env" {
  type        = string
  description = "Deployment environment (e.g. staging, prod)"
}

variable "dynamodb_arn" {
  type        = string
  description = "ARN of the DynamoDB table"
}

variable "prefix" {
  type = string
}

variable "role_name" {
  type        = string
  description = "IAM Role name"
}
