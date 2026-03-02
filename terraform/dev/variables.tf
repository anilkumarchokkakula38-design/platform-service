variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "image" {
  description = "Container image URL"
  type        = string
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "platform-service-dev"
}

variable "cpu" {
  description = "CPU allocation for dev environment"
  type        = string
  default     = "0.25"
}

variable "memory" {
  description = "Memory allocation for dev environment"
  type        = string
  default     = "128Mi"
}

variable "min_instances" {
  description = "Minimum number of instances for dev environment"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances for dev environment"
  type        = number
  default     = 5
}

variable "log_level" {
  description = "Log level for dev environment"
  type        = string
  default     = "DEBUG"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    environment = "dev"
    team        = "platform"
  }
}
