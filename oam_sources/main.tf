# Create a OAM link for the given OAM sink
# Create a policy for the CloudWatch-CrossAccountSharingRole which is created by AWS
# See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Cross-Account-Cross-Region.html
# Inspired by https://gds.blog.gov.uk/2023/07/26/enabling-aws-cross-account-monitoring-using-terraform/
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "aws_oam_sink_arn" {
  type        = string
  description = "The arn of the OAM sink to use in the OAM link"
}

variable "aws_account_id_monitoring" {
  type        = string
  description = "The ID of the monitoring account"
}

locals {
  managed_policies_to_attach = ["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess", "arn:aws:iam::aws:policy/CloudWatchAutomaticDashboardsAccess", "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"]
}

resource "aws_oam_link" "aws_oam_link_source_account" {
  label_template  = "$AccountName"
  resource_types  = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::ApplicationInsights::Application"]
  sink_identifier = var.aws_oam_sink_arn
}

data "aws_iam_policy_document" "iam_oam_service_account_trust_policy_document" {
  statement {
    sid     = "CrossAccountSharingRoleTrust"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.aws_account_id_monitoring]
    }
  }
}

resource "aws_iam_role" "iam_role_service_account_role" {
  name               = "CloudWatch-CrossAccountSharingRole"
  assume_role_policy = data.aws_iam_policy_document.iam_oam_service_account_trust_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iam_role_service_account_role_attach" {
  for_each = toset(local.managed_policies_to_attach)

  policy_arn = each.key
  role       = aws_iam_role.iam_role_service_account_role.name
}
