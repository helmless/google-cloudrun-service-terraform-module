output "service_account" {
  description = "The service account used by the Cloud Run service. Uses the provided service account if create_service_account is false, otherwise creates a new service account."
  value       = local.service_account
}

output "cloud_run_service" {
  description = "The full Cloud Run service object and all attributes."
  value       = google_cloud_run_v2_service.cloud_run_service
}

