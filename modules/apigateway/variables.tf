# variables for deplyment

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "ARN of the Lambda function to integrate"
  type        = string
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "prefix" {
  type        = string
}
variable "api_gateway_name" {
  type        = string
}
