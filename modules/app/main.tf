variable "region" {
  type = string
}

variable "environment" {
  type    = string
  default = "unknown"
}

output "region_out" {
  value = var.region
}

output "environment_out" {
  value = var.environment
}