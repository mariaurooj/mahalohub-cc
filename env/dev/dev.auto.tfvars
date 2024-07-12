
######SG
sg = {
  
  port = "80"
  port1 = "3000"
  port2 = "81"
  port3 = "22"
  "ingress1" = {
    port = "443"
    ingress1_protocol    = "tcp"
    ingress1_cidr_blocks = "0.0.0.0/0"
  }
  "ingress2" = {
    port = "5050"
    ingress2_protocol    = "tcp"
    ingress2_cidr_blocks = "0.0.0.0/0"
  }
  "egress" = {
    port = "0"
    egress1_protocol    = "-1"
    egress1_cidr_blocks = "0.0.0.0/0"
  }
}

######ECS
ecs = {
  desired_count = 1
  "container_def" = {
    image     = "383798767483.dkr.ecr.us-east-1.amazonaws.com/dev-mahalohub-closed_captioning:latest"
    cpu       = 3000
    memory    = 12842
    essential = true
  }
  "portmappings" = {
    containerport = 80
    containerport1 = 3000
    hostport      = 80 
  }
}
asg = {
  scaling_adjustment        = 1
  scaling_adjustment1       = -1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 60
  cooldown1                 = 300
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  protect_from_scale_in     = true
  default_cooldown          = 300
  health_check_grace_period = 180
  health_check_type         = "EC2"
  instance_type             = "g4ad.xlarge"
  "tag" = {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  "managed_scaling" = {
    instance_warmup_period    = 180
    maximum_scaling_step_size = 10
    minimum_scaling_step_size = 1
    status                    = "ENABLED"
    target_capacity           = 1
  }
  "default_capacity_provider_strategy" = {
    base   = 1
    weight = 1
  }
  "network_interfaces" = {
    associate_public_ip_address = true
    delete_on_termination       = false
  }
}
alb = {
  internal                      = false
  load_balancer_type            = "application"
  enable_deletion_protection    = false
  port                          = "80"
  port2                         = "81"
  protocol                      = "HTTP"
  port1                         = "443"
  protocol1                     = "HTTPS"
  "redirect" = {
    redirectport                = "443"
    redirectprotocol            = "HTTPS"      
    status_code                 = "HTTP_301"   
  }
  "health_check" = {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200-404"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}
### General
prefix = "mahalohub"
environment = "dev"
