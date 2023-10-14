provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      repo      = "ethereum-nodes-example"
      component = "ecr"
    }
  }
}