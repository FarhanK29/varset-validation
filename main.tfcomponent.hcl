required_providers {
  random = {
    source  = "hashicorp/random"
    version = "~> 3.9.0"
  }
}

provider "random" "this" {}

  source = "./modules/app"

  providers = {
    random = provider.random.this
  }

  inputs = {
    region      = store.varset.my-varset.region
    environment = store.varset.my-varset.environment
  }
}


store "varset" "my-varset" {
  # Update this to reference your varset by external ID or name
  name = "tc1-stack-varset"     # reference by name
}