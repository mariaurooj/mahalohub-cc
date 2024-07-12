data "aws_ssm_parameter" "ecs_ami_recommendation" {
  name  = "/aws/service/ecs/optimized-ami/amazon-linux-2/gpu/recommended"
}

locals {
  ami_info = jsondecode(data.aws_ssm_parameter.ecs_ami_recommendation.value)
}

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-01410dc27c4986055"]
  }
}