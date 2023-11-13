# Elastic Container Registry Module

This module creates a private ECR image in the default registry. It also creates a repository policy and a repository
lifecycle policy.

## Variables
### repository_name
This is mandatory and is used as the name of the repository

### allowed_principals
A list of principals to add to the default policy. If these are not provided, and a repository_policy is not provided, the principal in `default_policy.json.tpl` defaults to the calling account id. 

### repository_policy
The policy to attach to the repository to allow access. 
If this is not provided, the policy in default_policy.json.tpl is used with either the allowed_principals list or the calling account number.

### expire_untagged_images_days
The repository is set up with a lifecycle rule to delete untagged images after this many days. Defaults to 7.
This policy can be overwritten by providing a value for `lifecycle_policy`

### lifecycle_policy
A repository lifecycle policy. If one is not provided, the policy in `expire_untagged_x_days.json.tpl` is used with the value of `expire_untagged_images_days`
