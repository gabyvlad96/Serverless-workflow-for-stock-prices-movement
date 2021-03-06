{  
    "Version": "2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Action": [
            "dynamodb:BatchGetItem",
            "dynamodb:GetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:BatchWriteItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem"
        ],
        "Resource": [
            "${pricesTableArn}",
            "${hDataTableArn}"
        ]
     },
     {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
        ],
        "Resource": "${sqsQueueArn}"
    },
    {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "*"
    }
    ]
  }