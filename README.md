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
