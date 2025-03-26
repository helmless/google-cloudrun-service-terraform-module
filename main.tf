locals {
  deployment_accounts = concat(["serviceAccount:${local.service_account.email}"], var.deployment_accounts)

  # Creates a map of iam_role -> members keyed by the role
  iam_map = {
    for iam in var.iam : iam.role => { members = iam.members }
  }

  project         = var.project != null ? var.project : data.google_project.current.project_id
  service_account = var.create_service_account ? google_service_account.cloud_run_service_account[0] : data.google_service_account.cloud_run_service_account[0]
}

data "google_project" "current" {}

resource "google_cloud_run_v2_service" "cloud_run_service" {
  name        = var.name
  description = var.description
  location    = var.region
  labels      = var.labels

  deletion_protection = var.deletion_protection

  # All of the following inputs are managed by Helmless chart and deployment.
  template {
    service_account = local.service_account.email
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  # This will make the app pipeline with Helmless the authoritive source of truth for the service.
  lifecycle {
    ignore_changes = [
      template,
      ingress,
      launch_stage,
      labels,
      traffic,
      binary_authorization,
      client,
      client_version,
      description,
    ]
  }
}

data "google_service_account" "cloud_run_service_account" {
  count = var.create_service_account ? 0 : 1

  account_id = var.service_account_email
  project    = local.project
}

resource "google_service_account" "cloud_run_service_account" {
  count = var.create_service_account ? 1 : 0

  account_id   = var.name
  display_name = var.name
  project      = local.project
}

resource "google_service_account_iam_member" "service_account_user" {
  count = length(local.deployment_accounts)

  service_account_id = local.service_account.id
  role               = "roles/iam.serviceAccountUser"
  member             = local.deployment_accounts[count.index]
}

resource "google_cloud_run_v2_service_iam_member" "run_admin" {
  count = length(local.deployment_accounts)

  name     = google_cloud_run_v2_service.cloud_run_service.name
  location = var.region
  role     = "roles/run.admin"
  member   = local.deployment_accounts[count.index]
}

resource "google_cloud_run_v2_service_iam_binding" "custom_iam" {
  for_each = local.iam_map

  name     = google_cloud_run_v2_service.cloud_run_service.name
  location = var.region
  role     = each.key
  members  = each.value.members
}
