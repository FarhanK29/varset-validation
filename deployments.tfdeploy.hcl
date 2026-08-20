store "varset" "my-varset" {
  name     = "tc3-update-varset"
  category = "terraform"
}

deployment "production" {
  inputs = {
    environment = store.varset.my-varset.stable.environment
    region      = store.varset.my-varset.stable.region
  }
}
