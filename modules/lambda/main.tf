resource "aws_lambda_function" "this" {
  function_name = "${var.env}-${var.function_name}"
  role          = var.role_arn
  handler       = "app.lambda_handler"
  runtime       = "python3.12"

  filename         = var.package
  source_code_hash = var.package_hash != null ? var.package_hash : filebase64sha256(var.package)
  publish          = true

  environment {
    variables = {
      TABLE_NAME = var.table_name
      ENV        = var.env
    }
  }
}

resource "aws_lambda_alias" "env" {
  name             = var.env
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.retention_in_days
}
