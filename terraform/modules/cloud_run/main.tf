resource "google_cloud_run_service" "platform_service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.image

        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }

        ports {
          container_port = 8080
        }

        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }

        dynamic "env" {
          for_each = var.environment_variables
          content {
            name  = env.key
            value = env.value
          }
        }

        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 10
          period_seconds        = 30
          timeout_seconds       = 5
          failure_threshold     = 3
        }

        startup_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 0
          period_seconds        = 10
          timeout_seconds       = 3
          failure_threshold     = 3
        }
      }

      timeout_seconds = 60
      service_account_name = google_service_account.cloud_run_sa.email
    }

    metadata {
      labels = merge(
        var.labels,
        {
          environment = var.environment
          managed-by  = "terraform"
        }
      )
      annotations = {
        autoscaling.knative.dev/minScale = var.min_instances
        autoscaling.knative.dev/maxScale = var.max_instances
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_service_account.cloud_run_sa]

  lifecycle {
    ignore_changes = [
      metadata.0.annotations,
    ]
  }
}

resource "google_cloud_run_service_iam_binding" "public_invocation" {
  count   = var.allow_unauthenticated ? 1 : 0
  service = google_cloud_run_service.platform_service.name
  role    = "roles/run.invoker"
  members = ["allUsers"]
  location = var.region
  project  = var.project_id
}

# Service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${replace(var.service_name, "-", "_")}_sa_${var.environment}"
  display_name = "Service account for ${var.service_name} (${var.environment})"
  project      = var.project_id
}

resource "google_project_iam_member" "cloud_run_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_run_metrics" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
