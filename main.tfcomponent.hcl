required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
}

component "app" {
  source = "./modules/app"

  # Pull variables from a varset store named "my-varset"
  inputs = {
    region      = store.varset.my-varset.region
    environment = store.varset.my-varset.environment
  }
}

store "varset" "my-varset" {
  # Update this to reference your varset by external ID or name
  # id = "varset-xxxxxxxxxxxx"   # reference by external ID
  # name = "my-stack-varset"     # reference by name
}