output "service_url" {
  description = "Development service URL"
  value       = module.cloud_run_service.service_url
}

output "service_name" {
  description = "Development service name"
  value       = module.cloud_run_service.service_name
}
