resource "aws_ecr_repository" "repos" {
  for_each = toset(local.repositories)

  name = "${local.name}/${each.value}"
  # Note: In production, tags should be immutable and image scanning should be activated
  image_tag_mutability = "MUTABLE"
}