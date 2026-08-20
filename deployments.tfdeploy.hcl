store "varset" "my-varset" {
  name     = "tc6-scoped-varset"
  category = "terraform"
}

deployment "production" {
  inputs = {
    region      = store.varset.my-varset.stable.region
    environment = store.varset.my-varset.stable.environment
  }
}

deployment "staging" {
  inputs = {
    region      = "us-west-1"   # hardcoded — does not use the varset
    environment = "staging"     # hardcoded — does not use the varset
  }
}