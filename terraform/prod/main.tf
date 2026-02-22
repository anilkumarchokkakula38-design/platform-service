module "cloud_run_service" {
  source = "../modules/cloud_run"

  project_id    = var.project_id
  service_name  = var.service_name
  region        = var.region
  image         = var.image
  environment   = "prod"
  cpu           = var.cpu
  memory        = var.memory
  min_instances = var.min_instances
  max_instances = var.max_instances

  environment_variables = {
    LOG_LEVEL = var.log_level
  }

  labels = var.labels
}
