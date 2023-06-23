{
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "${log_group_arn}",
        "${log_group_arn}:log-stream:*"
      ]
    },
    {
      "Action": [
        "logs:DescribeLogGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
