store "varset" "my-varset" {
  id       = "varset-4aK9PSJuZmuJbRSt"   # replace with the actual ID from step 2
  category = "terraform"
}

deployment "production" {
  inputs = {
    region      = store.varset.my-varset.stable.region
    environment = store.varset.my-varset.stable.environment
  }
}
