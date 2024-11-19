locals {
  service_account     = var.create_service_account ? google_service_account.cloud_run_v2[0].email : var.service_account
  deployment_accounts = concat(var.deployment_accounts, ["serviceAccount:${local.service_account}"])

  # Flattens "iam" list of object list to list of objects
  flat_iam_list = flatten([
    for iam_idx, iam in var.iam : [
      for role_idx, member in iam.members : {
        role   = iam.role
        member = member
      }
    ]
  ])

  # Transforms flattened list to object map
  flat_iam_map = {
    for idx, flat_iam in local.flat_iam_list : idx => flat_iam
  }
}

resource "google_cloud_run_v2_service" "cloud_run_v2" {
  name        = var.name
  description = var.description
  location    = var.region
  labels      = var.labels

  # All of the following inputs are managed by Helmless chart and deployment.
  template {
    service_account = local.service_account
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
  lifecycle {
    ignore_changes = [
      template,
      location,
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

resource "google_service_account" "cloud_run_v2" {
  count = var.create_service_account ? 1 : 0

  account_id   = var.name
  display_name = var.name
}

resource "google_service_account_iam_member" "cloud_run_v2" {
  for_each = toset(var.deployment_accounts)

  service_account_id = google_service_account.cloud_run_v2[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value
}

resource "google_cloud_run_v2_service_iam_member" "deployment_accounts" {
  for_each = toset(local.deployment_accounts)

  name   = google_cloud_run_v2_service.cloud_run_v2.name
  role   = "roles/run.admin"
  member = each.value
}

resource "google_cloud_run_v2_service_iam_binding" "iam" {
  for_each = local.flat_iam_map

  name    = google_cloud_run_v2_service.cloud_run_v2.name
  role    = each.value.role
  members = each.value.members
}
