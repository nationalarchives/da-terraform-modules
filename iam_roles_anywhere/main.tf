data "http" "ca-cert-bundle" {
  count = var.trust_anchor_arn == null ? 1 : 0
  url   = var.x509_cert_location
}

resource "aws_rolesanywhere_trust_anchor" "ds-ca-prod" {
  count = var.trust_anchor_arn == null ? 1 : 0
  name  = "ds-ca-prod"
  source {
    source_type = "CERTIFICATE_BUNDLE"
    source_data {
      x509_certificate_data = data.http.ca-cert-bundle[0].response_body
    }
  }
  enabled = true
}

locals {
  trust_anchor_arn = coalesce(var.trust_anchor_arn, aws_rolesanywhere_trust_anchor.ds-ca-prod[0].arn)
}

# best practice is one certificate per role
module "iam_role" {
  for_each = var.roles
  source   = "git::https://github.com/nationalarchives/da-terraform-modules//iam_role?ref=main"
  name     = each.key
  assume_role_policy = templatefile("${path.module}/templates/ra_role_policy.json.tpl", {
    anchor_arn      = coalesce(var.trust_anchor_arn, aws_rolesanywhere_trust_anchor.ds-ca-prod[0].arn)
    x509_subject_cn = each.value.x509_subject_cn
    x509_subject_ou = each.value.x509_subject_ou
  })
  policy_attachments = each.value.policy_attachments
  tags               = each.value.tags
}

# best practice is one role per profile
resource "aws_rolesanywhere_profile" "ra_profiles" {
  for_each  = var.roles
  name      = each.key
  role_arns = [module.iam_role[each.key].role_arn]
  session_policy = each.value.allowed_subnets == null ? null : templatefile("${path.module}/templates/ip_restriction.json.tpl", {
    allowed_subnets = values(each.value.allowed_subnets)[*]
  })
  enabled = true
}

