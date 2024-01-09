resource "aws_ecr_repository" "devops_app" {
	name                 = "devops-app"
	image_tag_mutability = "MUTABLE"
  
	image_scanning_configuration {
	  scan_on_push = true
	}
  }