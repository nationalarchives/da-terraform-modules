output "trust_anchor_arn" {
  value       = local.trust_anchor_arn
  description = "IAM -> Roles -> scroll down -> Manage -> Trust Anchors"
}

output "profiles" {
  value       = aws_rolesanywhere_profile.ra_profiles
  description = "IAM -> Roles -> scroll down -> Manage -> Profiles (and Roles under that)"
}

output "roles" {
  value       = module.iam_role
  description = "IAM -> Roles -> scroll down -> Manage -> Profiles (and Roles under that)"
}

output "aws_signing_helper_command" {
  value = {
    for k, v in aws_rolesanywhere_profile.ra_profiles : k => join(" ", [
      "aws_signing_helper", "credential-process",
      "--certificate", "'${k}.pem'",
      "--private-key", "'${k}.key'",
      "--trust-anchor-arn", "'${local.trust_anchor_arn}'",
      "--profile-arn", "'${v.arn}'",
      "--role-arn", "'${module.iam_role[k].role_arn}'"
    ])
  }
  description = "output and use this to sign in with Roles Anywhere(TM) using the aws_signing_helper, you may need to change the cert files names"
}
