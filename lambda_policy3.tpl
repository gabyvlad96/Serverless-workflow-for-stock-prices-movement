{  
    "Version": "2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Action": [
            "dynamodb:DescribeStream",
            "dynamodb:GetRecords",
            "dynamodb:GetShardIterator",
            "dynamodb:ListStreams"
        ],
        "Resource": [
            "${pricesTableStreamArn}"
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
            "ses:SendEmail",
            "ses:SendRawEmail"
        ],
        "Resource": "*"
      }
    ]
  }