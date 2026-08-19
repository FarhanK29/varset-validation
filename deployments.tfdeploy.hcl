store "varset" "my-varset" {
  name     = "tc1c-global-varset"
  category = "terraform"
}

deployment "production" {
  inputs = {
    environment = store.varset.my-varset.stable.environment
    region      = store.varset.my-varset.stable.region
  }
}
