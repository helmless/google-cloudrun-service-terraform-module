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
  source              = "github.com/helmless/google-workload-identity-federation-terraform-module?ref=v0.1.0"
  id                  = "github"
  github_organization = "helmless"
}

module "cloudrun_service" {
  # source = "github.com/helmless/google-cloudrun-service-terraform-module?ref=v0.1.1" # x-release-please-version
  source = "../"
  name   = "example-service"

  create_service_account = true
  deployment_accounts    = ["${module.github_federation.repository_principal_set_id_prefix}/example-repository"]
}
```

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Cloud Run service. Must be unique within the project and region.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account)

Description: Whether to create a service account for the Cloud Run service with the same name as the service. If not provided, the default service account will be used.

Type: `bool`

Default: `false`

### <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection)

Description: Whether to enable deletion protection for the Cloud Run service.

Type: `bool`

Default: `true`

### <a name="input_deployment_accounts"></a> [deployment\_accounts](#input\_deployment\_accounts)

Description: A list of accounts that are allowed to deploy the Cloud Run service. Must be in the format of 'serviceAccount:ACCOUNT\_EMAIL' or principalSet:PRINCIPAL\_SET\_ID. The accounts will get the roles/run.admin role on the Cloud Run service and the roles/iam.workloadIdentityUser role on the service account.

Type: `list(string)`

Default: `[]`

### <a name="input_description"></a> [description](#input\_description)

Description: An optional description of the Cloud Run service.

Type: `string`

Default: `""`

### <a name="input_iam"></a> [iam](#input\_iam)

Description: A list of IAM bindings to apply to the Cloud Run service.

Type:

```hcl
list(object({
    role    = string
    members = list(string)
  }))
```

Default: `[]`

### <a name="input_labels"></a> [labels](#input\_labels)

Description: Labels to apply to the Cloud Run service.

Type: `map(string)`

Default: `{}`

### <a name="input_region"></a> [region](#input\_region)

Description: The region to deploy the Cloud Run service to.

Type: `string`

Default: `"us-central1"`

### <a name="input_service_account"></a> [service\_account](#input\_service\_account)

Description: The service account to use for the Cloud Run service. If not provided, the default service account will be used.

Type: `string`

Default: `null`

## Outputs

No outputs.

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9.6, < 2)

- <a name="requirement_google"></a> [google](#requirement\_google) (>= 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_google"></a> [google](#provider\_google) (6.12.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [google_cloud_run_v2_service.cloud_run_v2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) (resource)
- [google_cloud_run_v2_service_iam_binding.iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_binding) (resource)
- [google_cloud_run_v2_service_iam_member.deployment_accounts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) (resource)
- [google_service_account.cloud_run_v2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) (resource)
- [google_service_account_iam_member.cloud_run_v2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) (resource)
<!-- END_TF_DOCS -->
