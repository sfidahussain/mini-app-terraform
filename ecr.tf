resource "aws_ecr_repository" "be" {
  name                 = "be"
}

resource "aws_ecr_repository" "fe" {
  name                 = "fe"
}