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
  ephemeral = true
}

variable "environment" {
  type    = string
  ephemeral = true
  default = "unknown"
}
