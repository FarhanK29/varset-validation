required_providers {
  random = {
    source  = "hashicorp/random"
    version = "~> 3.9.0"
  }
}

provider "random" "this" {}

component "app" {
  source = "./modules/app"

  providers = {
    random = provider.random.this
  }

  inputs = {
    region      = var.region
    environment = var.environment
  }
}

variable "region" {
  type = string
}

variable "environment" {
  type    = string
  default = "unknown"
}

output "region_out" {
  type  = string
  value = component.app.region_out
}

output "environment_out" {
  type  = string
  value = component.app.environment_out
}