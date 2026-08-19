store "varset" "my-varset" {
  name     = "tc1-stack-varset"
  category = "terraform"
}

deployment "production" {
  inputs = {
    region      = store.varset.my-varset.region
    environment = store.varset.my-varset.environment
  }
}
