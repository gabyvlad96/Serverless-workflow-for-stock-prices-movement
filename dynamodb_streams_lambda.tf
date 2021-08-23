resource "aws_iam_role" "iam_for_lambda3" {
  name = "iam_for_lambda3"
  assume_role_policy = file("assume_role_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy3" {
  name = "lambda_policy"
  role = aws_iam_role.iam_for_lambda3.id

  policy = templatefile("lambda_policy3.tpl", { 
      pricesTableStreamArn = aws_dynamodb_table.stock_prices.stream_arn
      sqsQueueArn = aws_sqs_queue.sqs_queue.arn
    })
}

resource "aws_lambda_function" "prices_processor" {
  function_name = "prices_processor"
  filename      = "./stock_prices_processor_lambda/prices_processor.zip"
  source_code_hash = filebase64sha256("./stock_prices_processor_lambda/prices_processor.zip")

  role          = aws_iam_role.iam_for_lambda3.arn
  handler       = "stock_prices_processor.lambda_handler"
  runtime       = "python3.8"
  reserved_concurrent_executions = 2
  timeout       = 3
}

resource "aws_lambda_event_source_mapping" "mapping" {
  event_source_arn  = aws_dynamodb_table.stock_prices.stream_arn
  function_name     = aws_lambda_function.prices_processor.arn
  starting_position = "LATEST"
}