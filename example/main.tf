module "github_federation" {
  source = "ssh://git@github.com:helmless/google-workload-identity-federation-terraform-module.git"
  id = "github"
  github_organization = "helmless"
}

module "cloudrun_service" {
  source = "ssh://git@github.com:helmless/google-cloudrun-service-terraform-module.git?ref=v0.1.0" # x-release-please-version
  name   = "example-service"

  create_service_account = true
  iam = [
    {
      role    = "roles/run.admin"
      members = ["${module.github_federation.repository_principal_set_id_prefix}/example-repository"]
    }
  ]
}
