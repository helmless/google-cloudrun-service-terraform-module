# helmless/google-cloudrun-terraform-module

A [Terraform][terraform] module to create a wrapper around a Google Cloud Run Service or Job. The Cloud Run workload will be deployed using [Helmless](https://helmless.io) instead of Terraform. The module purely exists to have a reference to the cloud resource in order to apply IAM policies to it.

[goolge-cloud]: https://cloud.google.com
[terraform]: https://www.terraform.io

# asdf tools

This repository has a _.tools-versions_ file used by [asdf](https://asdf-vm.com/) to install the necessary tools. For this you need the following additional plugins:

```
asdf plugin add terraform-docs https://github.com/looztra/asdf-terraform-docs
asdf plugin add tflint https://github.com/skyzyx/asdf-tflint
asdf install
```

<!-- BEGIN_TF_DOCS -->

## Usage

```hcl
module "github_federation" {
  source              = "ssh://git@github.com:helmless/google-workload-identity-federation-terraform-module.git?ref=v0.1.0" # x-release-please-version
  github_organization = "helmless"
}
```

## Required Inputs

The following input variables are required:

### <a name="input_github_organization"></a> [github_organization](#input_github_organization)

Description: The GitHub organization to bind to the workload identity pool and provider

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_id"></a> [id](#input_id)

Description: The id of the workload identity pool and provider

Type: `string`

Default: `"github"`

## Outputs

The following outputs are exported:

### <a name="output_organization_principal_set_id"></a> [organization_principal_set_id](#output_organization_principal_set_id)

Description: The principal set id for the GitHub organization to be used in IAM policies and bindings. Warning: this will grant all repositories in your Github organization the IAM role you bind this to. Use the repository_principal_set_id for more granular control.

### <a name="output_pool_id"></a> [pool_id](#output_pool_id)

Description: The id of the workload identity pool. Example: projects/1234567890/locations/global/workloadIdentityPools/github

### <a name="output_provider_id"></a> [provider_id](#output_provider_id)

Description: The id of the workload identity provider.

### <a name="output_repository_principal_set_id_prefix"></a> [repository_principal_set_id_prefix](#output_repository_principal_set_id_prefix)

Description: The principal set id for the GitHub repository to be used in IAM policies and bindings. You must append the repository name to this id to use it.

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement_terraform) (>= 1.9.6, < 2)

- <a name="requirement_google"></a> [google](#requirement_google) (>= 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_google"></a> [google](#provider_google) (6.12.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [google_iam_workload_identity_pool.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) (resource)
- [google_iam_workload_identity_pool_provider.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) (resource)
<!-- END_TF_DOCS -->
