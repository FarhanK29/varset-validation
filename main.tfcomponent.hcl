required_providers {
  random = {
    source  = "hashicorp/random"
    version = "~> 3.9.0"
  }
}

provider "random" "this" {}

component "app" {
  source = "./app"

  providers = {
    random = provider.random.this
  }

  inputs = {
    region      = store.varset.my-varset.region
    environment = store.varset.my-varset.environment
  }
}

# Fill in `name` or `id` for each test case before pushing
store "varset" "my-varset" {
  name = "tc1-stack-varset"
}
