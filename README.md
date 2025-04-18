# Digital Archiving Terraform Modules

This is a repository of terraform modules which can be used to create resources within AWS. 

## Modules
There are the following modules:

## S3
Creates an S3 bucket with an optional bucket policy, all public access blocked and an optional logging bucket.

## Dynamo
Creates a Dynamo DB table. 

## GitHub Repository Secrets
Set repository secrets in GitHub

## GitHub Environment Secrets
Set environment secrets in GitHub

## Lambda
Create lambdas

## Cloudwatch Alarms
Creates a cloudwatch alarm. Can send to a lambda, an SQS, an SNS topic or a mix of all of them.

## Cloudwatch Events
Creates a cloudwatch event based on either an event pattern or a schedule. Can send to a lambda, an SQS, an SNS topic or a mix of all of them.

## IAM Policy
Creates an IAM policy from a string

## IAM Role
Creates an IAM role and attaches the policies passed to it.

## KMS
Creates A KMS key. 

It also creates an admin role which has permissions to administer the key but not to decrypt or encrypt with it. 
The trust policy of this role is set to deny access to everything. To assume this role, you will need to change the trust policy.

The key policy allows the root user full KMS permissions. You can optionally provide lists of roles which will be added to the key policy.
* User roles - these have permissions to decrypt and encrypt but not to make changes to the key.
* CI roles - these have permissions to administer the key but not to delete it or use it to encrypt and decrypt.
* Persistent resource roles - these have permissions to grant other AWS services access to the key.
* Service names - a list of AWS services which are permitted to use the key. Only the service name is needed, e.g. cloudwatch instead of cloudwatch.amazonaws.com
  There is a condition on this statement that only services within the calling account can access the key.

If any of these roles or services are not provided, the relevant policy statements won't be added. 

## SSM Parameter
Takes a list of objects describing the ssm parameters. You can optionally ignore value changes so terraform won't overwrite changes made elsewhere.

## VPC
Creates a VPC with public security groups routing through an internet gateway and private security groups through a NAT gateway.

## SNS
Creates an SNS queue. A list of Lambda or SQS can be passed and will be subscribed to this queue.

## SQS
Creates an SQS queue.

## Security Group
Creates a security group with rules passed to it.

## WAFv2 AWS Managed Rules
Creates a set of AWS managed WAF rules to be associated with the given AWS resources.

Provides a default set of AWS managed rules. The default rules are "free" and non-language and non-OS specific:
* `AWSManagedRulesAmazonIpReputationList`
* `AWSManagedRulesCommonRuleSet`
* `AWSManagedRulesCommonRuleSet`

Calling modules can choose whatever set of AWS managed rules are most appropriate for the particular service and are not restricted to the default rules.

Full list of the available AWS managed rules is available here: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html

## AWS Access Analyzer

This Terraform module provisions an **AWS Access Analyzer** instance and optionally defines an **archive rule** to filter findings. The archive rule supports customizable criteria using comparators such as `contains`, `eq`, `exists`, and `neq`.

For detailed usage and configuration, refer to the [Access Analyzer Module README](./access_analyzer/README.md).

## Using the modules
You can either clone this repository into the root of your existing terraform project and reference the modules directly
```hcl
module "example_module" {
  source = "./da-terraform-modules/s3"
```

Or you can reference it as a remote git repository. This syntax is preferred by IntelliJ
```hcl
module "example_module" {
  source = "git::https://github.com/nationalarchives/da-terraform-modules.git//s3"
```

## Development
The test job which runs against a pull request, runs `terraform fmt --check` which fails if the terraform is not formatted correctly.
Run `terraform fmt --recursive` to avoid this.

## Testing

It might be best to test your changes before merging into the main, if you would like to do so:

1. create a GitHub branch and push it
2. in a local `terraform-environments` repo of your choosing, find a relevant module, e.g. if your change is an SQS change, find an SQS module
3. you should see that the `source` field ends with `\\[AWS service]"`
4. at the end of the AWS service, add `?ref=[Remote branch name]`
5. run `terraform init` to get the changes
6. now in your local `terraform-environments` repo, you can run `terraform plan` and/or `terraform apply` to see what affect it will have
