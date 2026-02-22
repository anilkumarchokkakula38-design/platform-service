output "service_url" {
  description = "The URL of the deployed service"
  value       = google_cloud_run_service.platform_service.status[0].url
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_service.platform_service.name
}

output "service_region" {
  description = "The region where the service is deployed"
  value       = var.region
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}
