# Create a Observability Access Manager Sink
# Creating a sink effectively makes the account a "monitoring" account
variable "source_oam_account_ids" {
  type        = list(string)
  description = "List of source accounts to use in the OAM sink policy"
}

resource "aws_oam_sink" "oam_sink" {
  name = "AccountSink"
}

data "aws_iam_policy_document" "oam_sink_policy" {
  statement {
    sid       = "OamSinkPolicy"
    effect    = "Allow"
    actions   = ["oam:CreateLink", "oam:UpdateLink"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = var.source_oam_account_ids
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "oam:ResourceTypes"
      values   = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::ApplicationInsights::Application"]
    }
  }
}

resource "aws_oam_sink_policy" "oam_sink_policy" {
  sink_identifier = aws_oam_sink.oam_sink.id
  policy          = data.aws_iam_policy_document.oam_sink_policy.json
}
