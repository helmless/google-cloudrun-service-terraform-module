variable "name" {
  description = "The name of the Cloud Run service. Must be unique within the project and region."
  type        = string
}

variable "description" {
  description = "An optional description of the Cloud Run service."
  type        = string
  default     = ""
}

variable "project" {
  description = "The project to deploy the Cloud Run service to."
  type        = string
  default     = null
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

variable "service_account_email" {
  description = "The service account email to use for the Cloud Run service. If not provided, the default service account will be used."
  type        = string
  default     = null
  validation {
    condition     = var.create_service_account == true || var.service_account_email != null
    error_message = "service_account_email must be provided if create_service_account is false"
  }
}

variable "create_service_account" {
  description = "Whether to create a service account for the Cloud Run service with the same name as the service. If not provided, the default service account will be used."
  type        = bool
  default     = true
}

variable "deployment_accounts" {
  description = "A list of accounts that are allowed to deploy the Cloud Run service. Must be in the format of 'serviceAccount:ACCOUNT_EMAIL' or principalSet:PRINCIPAL_SET_ID. The accounts will get the roles/run.admin role on the Cloud Run service and the roles/iam.workloadIdentityUser role on the service account."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue(flatten([for account in var.deployment_accounts : can(regex("^serviceAccount:.*", account)) || can(regex("^principalSet:.*", account))]))
    error_message = "All deployment accounts must be in the format of 'serviceAccount:ACCOUNT_EMAIL' or 'principalSet:PRINCIPAL_SET_ID'"
  }
}

variable "iam" {
  description = "A list of IAM bindings to apply to the Cloud Run service."
  type = list(object({
    role    = string
    members = list(string)
  }))
  default = []
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the Cloud Run service."
  type        = bool
  default     = true
}
