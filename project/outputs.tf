output "lambda_arn" {
  value = module.lambda.arn
}

output "lambda_cw_log_group" {
  value = module.lambda.cw_log_group
}

output "api_endpoint" {
  value = module.api.api_endpoint
}

output "api_id" {
  value = module.api.api_id
}
