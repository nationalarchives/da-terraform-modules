### iam_roles_anywhere module

This module effectively takes a list of resource access policies and returns a list of (profile, role) ARN pairs as well as creating and returning the ARN of a trust anchor that those profiles trust to verify identity.  Optionally the trust anchor can be specified (by ARN or URL to a .pem bundle) and you can specify allowed source IP ranges for the sesion profile.

What you can't do:
- reuse existing roles - use the policies from them instead, as managed policies
- use inline policies - this restriction is inherited from the da_terraform_modules/iam_role module that's used underneath
- specify a more complex session policy - most things other than IP restrictions belong in the resource policy used in policy_attachments.  You would need to add it manually or add code to this module
- match other attributes on the certificate e.g. SAN - you would need to add code to this module

Example code to use this module:

```
module "my_local_system_profile" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules//iam_roles_anywhere?ref=main"
  roles = {
    "my local system" = {
      x509_subject_cn      = "Dave's local system"
      policy_attachments   = { "my policy" = local.my_policy_arn }
      allowed_subnets      = { "Kew site proxy outbound address" = "137.221.134.222/32" }
    }
  }
}
```

It's recommended to output the following from your code using this module.  Then, every time you terraform apply, it will give you the exact command you can copy and paste for your system to log in with roles anywhere.

```
output "aws_signin_helper_command" {
  value = module.my_local_system_profile.aws_signin_helper_command
}
```