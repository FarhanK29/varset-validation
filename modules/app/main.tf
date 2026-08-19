terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
}

variable "region" {
  type        = string
  description = "Simulated deployment region — sourced from a varset store"
}

variable "environment" {
  type        = string
  default     = "unknown"
  description = "Simulated environment name — sourced from a varset store"
}

# Use the variable in a resource so Terraform actually does work with it
resource "random_string" "label" {
  length  = 8
  special = false
  upper   = false
  keepers = {
    region      = var.region
    environment = var.environment
  }
}

output "region_out" {
  value       = var.region
  description = "The region value that was passed in — verify this matches your varset"
}

output "environment_out" {
  value       = var.environment
  description = "The environment value that was passed in — verify this matches your varset"
}