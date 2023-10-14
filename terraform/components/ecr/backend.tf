provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      component = "ecr"
      #      TODO:
      repo = "ethereum-node-poc"
    }
  }
}