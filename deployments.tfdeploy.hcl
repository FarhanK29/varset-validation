store "varset" "my-varset" {
  name = "tc8-stack-varset"
  category = "terraform"
}

deployment "production" {
  inputs = {
    region      = store.varset.my-varset.stable.region
    environment = store.varset.my-varset.stable.environment
  }
}
