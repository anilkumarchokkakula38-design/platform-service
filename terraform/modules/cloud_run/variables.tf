variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be 'dev' or 'prod'."
  }
}

variable "image" {
  description = "Container image URL"
  type        = string
}

variable "cpu" {
  description = "CPU allocation (0.25, 0.5, 1, 2, 4, or 6)"
  type        = string
  default     = "0.25"
}

variable "memory" {
  description = "Memory allocation (e.g., 128Mi, 256Mi, 512Mi, 1Gi)"
  type        = string
  default     = "128Mi"
}

variable "min_instances" {
  description = "Minimum number of container instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of container instances"
  type        = number
  default     = 10
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated invocations"
  type        = bool
  default     = true
}

variable "environment_variables" {
  description = "Environment variables for the service"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to the service"
  type        = map(string)
  default     = {}
}
