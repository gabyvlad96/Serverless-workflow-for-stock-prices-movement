// Lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = file("assume_role_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy1" {
  name = "lambda_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = templatefile("lambda_policy1.tpl", { 
      pricesTableArn = aws_dynamodb_table.stock_prices.arn
      hDataTableArn = aws_dynamodb_table.historical_data.arn
      sqsQueueArn = aws_sqs_queue.sqs_queue.arn
    })
}

resource "aws_lambda_function" "data_loader" {
  function_name = "data_loader"
  filename      = "./data_loader_lambda/data_loader.zip"
  source_code_hash = filebase64sha256("./data_loader_lambda/data_loader.zip")

  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "data_loader.lambda_handler"
  runtime       = "python3.8"
  reserved_concurrent_executions = 1
  timeout       = 4
}

resource "aws_lambda_event_source_mapping" "sqs_lambda" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.data_loader.arn
}

// SQS Queue
resource "aws_sqs_queue" "sqs_queue" {
  name                      = "data-loader-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs_queue.id
  policy = templatefile("sqs_policy.tpl", { 
      sqsQueueArn = aws_sqs_queue.sqs_queue.arn
      cloudWatchArn = aws_cloudwatch_event_rule.cloudwatch_rule.arn
    })
}

// Cloudwatch alarm
resource "aws_cloudwatch_event_rule" "cloudwatch_rule" {
  name = "data-loader-trigger"
  schedule_expression = "cron(* 14-21 ? * 2-6 *)"
  is_enabled = false
}

resource "aws_cloudwatch_event_target" "sqs" {
  rule      = aws_cloudwatch_event_rule.cloudwatch_rule.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.sqs_queue.arn
}
