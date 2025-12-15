resource "aws_iam_role" "lambda" {
  name = "${var.env}-${var.role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.env}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        # Restrict permissions to CloudWatch Logs log groups
        Resource = "arn:aws:logs:*:*:log-group:*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = var.dynamodb_arn
      }
    ]
  })
}


