provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      component = "eks"
      #      TODO:
      repo = "ethereum-node-poc"
    }
  }
}