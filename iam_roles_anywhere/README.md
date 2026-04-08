### iam_roles_anywhere module

This module effectively takes a list of resource access policies and returns a
list of (profile, role) ARN pairs as well as creating and returning the ARN of
a trust anchor that those profiles trust to verify identity.  Optionally the
trust anchor can be specified (by ARN or URL to a .pem bundle) and you can
specify allowed source IP ranges for the sesion profile.

What you can't do:
- reuse existing roles - use the policies from them instead, as managed policies
- use inline policies - this restriction is inherited from the
  da_terraform_modules/iam_role module that's used underneath
- specify a more complex session policy - most things other than IP restrictions
  belong in the resource policy used in policy_attachments.  You would need to
  add it manually or add code to this module
- match other attributes on the certificate e.g. SAN - you would need to add
  code to this module
- have multiple roles with one profile - best practice is for each role to have
  their own profile.  They can share policies, or a single profile+role can have
  multiple policies

Example code to use this module is below.  Note the for comprehension in roles
object rather than for_each at the top level.  This avoids creating multiple
identical trust anchors (which will work, but is silly)

```
module "my_local_system_profile" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules//iam_roles_anywhere?ref=main"
  roles = {
    "my local system" = {
      x509_subject_cn      = "Dave's Laptop"
      policy_attachments   = { "my policy" = local.my_policy_arn }
    }
  }
}

module "lottery_machines_profile" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules//iam_roles_anywhere?ref=main"
  roles = {
    for k in tolist([ "Merlin", "Arthur", "Lancelot", "Guinevere" ]) : k => {
      x509_subject_cn      = each.value
      policy_attachments   = { "web-based RTC access" = local.rtc_policy_arn }
      # optionally restrict by subnet
      allowed_subnets      = k == "Guinevere" ? {
        "Science museum outbound" = local.smip
      } : {
        "Kew site proxy outbound address" = "137.221.134.222/32"
      }
    }
  }
}
```

It's recommended to output the following from your code using this module.
Then, every time you terraform apply, it will give you the exact command you can
copy and paste for your systems to log in with roles anywhere.

```
output "aws_signin_helper_command" {
  value = module.my_local_system_profile.aws_signin_helper_command
}
```