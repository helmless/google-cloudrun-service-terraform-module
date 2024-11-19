variable "name" {
  description = "The name of the Cloud Run service. Must be unique within the project and region."
  type        = string
}

variable "description" {
  description = "An optional description of the Cloud Run service."
  type        = string
  default     = ""
}

variable "region" {
  description = "The region to deploy the Cloud Run service to."
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Labels to apply to the Cloud Run service."
  type        = map(string)
  default     = {}
}

variable "service_account" {
  description = "The service account to use for the Cloud Run service. If not provided, the default service account will be used."
  type        = string
  default     = null
}

variable "create_service_account" {
  description = "Whether to create a service account for the Cloud Run service with the same name as the service. If not provided, the default service account will be used."
  type        = bool
  default     = false
}

variable "iam" {
  description = "A list of IAM bindings to apply to the Cloud Run service."
  type = list(object({
    role    = string
    members = list(string)
  }))
  default = []
}
