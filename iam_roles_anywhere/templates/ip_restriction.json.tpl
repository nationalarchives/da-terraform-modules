{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ${jsonencode(allowed_subnets)
          }
        },
        "Bool": {
          "aws:ViaAWSService": "false"
        }
      }
    }
  ],
  "Version": "2012-10-17"
}