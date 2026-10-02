resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public_1.id, aws_subnet.public_2.id
  ]

  tags = {
    Name = "${var.project_name}-alb"
  }
}

