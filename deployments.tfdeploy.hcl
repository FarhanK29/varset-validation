store "varset" "my-varset" {
  name     = "tc5-delete-varset"
  category = "terraform"
}

deployment "production" {
  inputs = {
    environment = store.varset.my-varset.stable.environment
    region      = store.varset.my-varset.stable.region
  }
}
