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
Creates A KMS key. It also creates an admin policy which has permissions to administer the key but not to decrypt of encrypt with it.
The key policy allows the root user full KMS permissions. You can optionally provide lists of roles which will be added to the key policy.
* User roles - these have permissions to decrypt and encrypt but not to make changes to the key.
* CI roles - these have permissions to administer the key but not to delete it or use it to encrypt and decrypt.
* Persistent resource roles - these have permissions to grant other AWS services access to the key.
If these roles are not provided, the relevant policy statements won't be added. 


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
The test job which runs against a pull request runs `terraform fmt --check` which fails if the terraform is not formatted correctly.
Run `terraform fmt --recursive` to avoid this.
