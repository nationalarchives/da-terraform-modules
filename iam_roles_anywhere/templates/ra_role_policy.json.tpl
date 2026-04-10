{
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole",
        "sts:TagSession",
        "sts:SetSourceIdentity"
      ],
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "rolesanywhere.amazonaws.com"
        ]
      },
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": [
            "${anchor_arn}"
          ]
        },
        "StringEquals": {
          "aws:PrincipalTag/x509Subject/CN": "${x509_subject_cn}",
          "aws:PrincipalTag/x509Subject/OU": "${x509_subject_ou}"
        }
      }
    }
  ],
  "Version": "2012-10-17"
}