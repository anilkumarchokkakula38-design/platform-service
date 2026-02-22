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
  default     = "platform-service"
}

variable "cpu" {
  description = "CPU allocation for prod environment"
  type        = string
  default     = "0.5"
}

variable "memory" {
  description = "Memory allocation for prod environment"
  type        = string
  default     = "256Mi"
}

variable "min_instances" {
  description = "Minimum number of instances for prod environment"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances for prod environment"
  type        = number
  default     = 20
}

variable "log_level" {
  description = "Log level for prod environment"
  type        = string
  default     = "INFO"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    environment = "prod"
    team        = "platform"
  }
}
