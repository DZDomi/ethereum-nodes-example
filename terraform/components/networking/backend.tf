provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      component = "networking"
      #      TODO:
      repo = "ethereum-node-poc"
    }
  }
}