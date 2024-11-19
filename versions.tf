terraform {
  required_version = ">= 1.9.6, < 2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}
