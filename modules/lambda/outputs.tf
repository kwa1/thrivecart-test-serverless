output "name" {
  value = aws_lambda_function.this.function_name
}

output "arn" {
  value = aws_lambda_function.this.arn
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "alias_arn" {
  value = aws_lambda_alias.env.arn
}
output "cw_log_group" {
  value = aws_cloudwatch_log_group.lambda.name
}
