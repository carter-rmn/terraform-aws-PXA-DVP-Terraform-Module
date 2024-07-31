resource "aws_lambda_function" "lambdas" {
  function_name = "${local.pxa_prefix}-event-lambda"
  handler       = "event_lambda.event"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_role.arn
  filename      = "src/event_function.zip"
  memory_size   = 128
  timeout       = 7

  vpc_config {
    subnet_ids         = local.vpc.subnets.private
    security_group_ids = [aws_security_group.sg_lambda.id]
  }

  layers = [
    aws_lambda_layer_version.event_layer.arn,
  ]

  tags = {
    Name        = "${local.pxa_prefix}-event-lambda"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_lambda_layer_version" "event_layer" {
  filename   = "layers/lambda_layer.zip"
  layer_name = "event-layer"
  
  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambdas.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}