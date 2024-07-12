
resource "aws_lb" "aws_alb" {
  name                       = "${var.environment}-${var.prefix}-loadbalancer"
  internal                   = var.alb.internal
  load_balancer_type         = var.alb.load_balancer_type
  security_groups            = [var.sg_id]
  subnets                    = ["subnet-035e3c258a22c8be8", "subnet-0e125d3fd64415646"]
  enable_deletion_protection = var.alb.enable_deletion_protection
  tags = {
    Name = "${var.environment}-${var.prefix}-closedcaptioning"
  }
}
resource "aws_lb_listener" "aws_Alb_listener" {
  load_balancer_arn = aws_lb.aws_alb.arn
  port              = var.alb.port
  protocol          = var.alb.protocol
  default_action {
    type = "redirect"

    redirect {
      port        = var.alb.redirect.redirectport
      protocol    = var.alb.redirect.redirectprotocol
      status_code = var.alb.redirect.status_code
    }
  }
  tags = {
    Name = "${var.environment}-${var.prefix}-closedcaptioning"
  }
}
resource "aws_lb_listener" "aws_alb_listener" {
  load_balancer_arn = aws_lb.aws_alb.arn
  port              = var.alb.port1
  protocol          = var.alb.protocol1
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:383798767483:certificate/0e19af59-5d6a-4e89-b358-b2977db9ee72"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
  tags = {
    Name = "${var.environment}-${var.prefix}-closedcaptioning"
  }
}
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.aws_alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.monitoringtargetgroup.arn
  }

  condition {
    host_header {
      values = ["monitoring.mymahalohub.com"]
    }
  }
}


resource "aws_lb_target_group" "targetgroup" {
  name        = "${var.environment}-${var.prefix}-closedcaptioning"
  target_type = "instance"
  port        = var.alb.port
  protocol    = var.alb.protocol
  vpc_id      = "vpc-0d93879d3d16ed774"
  health_check {
    enabled             = var.alb.health_check.enabled
    interval            = var.alb.health_check.interval
    path                = var.alb.health_check.path
    timeout             = var.alb.health_check.timeout
    matcher             = var.alb.health_check.matcher
    healthy_threshold   = var.alb.health_check.healthy_threshold
    unhealthy_threshold = var.alb.health_check.unhealthy_threshold
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.environment}-${var.prefix}-closedcaptioning"
  }
}
resource "aws_lb_target_group" "monitoringtargetgroup" {
  name        = "${var.environment}-${var.prefix}-monitoring"
  target_type = "ip"
  port        = var.alb.port2
  protocol    = var.alb.protocol
  vpc_id      = "vpc-0d93879d3d16ed774"
  health_check {
    enabled             = var.alb.health_check.enabled
    interval            = var.alb.health_check.interval
    path                = var.alb.health_check.path
    timeout             = var.alb.health_check.timeout
    matcher             = var.alb.health_check.matcher
    healthy_threshold   = var.alb.health_check.healthy_threshold
    unhealthy_threshold = var.alb.health_check.unhealthy_threshold
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.environment}-${var.prefix}-monitoring"
  }
}
