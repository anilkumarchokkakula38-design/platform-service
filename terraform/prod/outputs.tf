output "service_url" {
  description = "Production service URL"
  value       = module.cloud_run_service.service_url
}

output "service_name" {
  description = "Production service name"
  value       = module.cloud_run_service.service_name
}
