resource "aws_ecr_repository" "repos" {
  for_each = toset(local.repositories)

  name = "${local.name}/${each.value}"
  #   TODO:
  image_tag_mutability = "MUTABLE"
  #  encryption_configuration {
  #
  #  }

  #  image_scanning_configuration {
  #    scan_on_push = true
  #  }
}