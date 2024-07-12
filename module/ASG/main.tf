resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecsInstanceRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_autoscaling_group" "asg_ecs" {
  min_size                  = var.asg.min_size
  max_size                  = var.asg.max_size 
  desired_capacity          = var.asg.desired_capacity
  default_cooldown          = var.asg.default_cooldown
  health_check_grace_period = var.asg.health_check_grace_period
  health_check_type         = var.asg.health_check_type
  protect_from_scale_in     = var.asg.protect_from_scale_in
  vpc_zone_identifier       = ["subnet-035e3c258a22c8be8", "subnet-0e125d3fd64415646"]
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = aws_launch_template.ec2_launch_template.latest_version
  }
  tag {
    key                 = var.asg.tag.key
    value               = var.asg.tag.value
    propagate_at_launch = var.asg.tag.propagate_at_launch
  }
  name = "${var.environment}-${var.prefix}-asg"
}
resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.environment}-${var.prefix}-capacity_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg_ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      instance_warmup_period    = var.asg.managed_scaling.instance_warmup_period
      maximum_scaling_step_size = var.asg.managed_scaling.maximum_scaling_step_size
      minimum_scaling_step_size = var.asg.managed_scaling.minimum_scaling_step_size
      status                    = var.asg.managed_scaling.status
      target_capacity           = var.asg.managed_scaling.target_capacity
    }
  }
  tags = {
    Name = "${var.environment}-${var.prefix}-capacity_provider"
  }
}
resource "aws_ecs_cluster_capacity_providers" "cluster_capacityprovider_association" {
  cluster_name       = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

  default_capacity_provider_strategy {
    base              = var.asg.default_capacity_provider_strategy.base
    weight            = var.asg.default_capacity_provider_strategy.weight
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
  }
}
# Launch template

resource "aws_launch_template" "ec2_launch_template" {
  image_id      = data.aws_ami.ecs.id
  instance_type = var.asg.instance_type 
  network_interfaces {
    associate_public_ip_address = var.asg.network_interfaces.associate_public_ip_address
    delete_on_termination       = var.asg.network_interfaces.delete_on_termination
    security_groups             = [var.sg_id]
  }
  key_name = "mymahalohub"
  iam_instance_profile{
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    cluster_name = var.cluster_name                                      
  }))
  tags = {
    Name = "${var.environment}-${var.prefix}-closedcaptioning"
  }
}

resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "${aws_autoscaling_group.asg_ecs.name}-cpu-scale-up"
  scaling_adjustment     = var.asg.scaling_adjustment
  adjustment_type        = var.asg.adjustment_type
  cooldown               = var.asg.cooldown
  autoscaling_group_name = aws_autoscaling_group.asg_ecs.name
}

resource "aws_autoscaling_policy" "cpu_scale_down" {
  name                   = "${aws_autoscaling_group.asg_ecs.name}-cpu-scale-down"
  scaling_adjustment     = var.asg.scaling_adjustment1
  adjustment_type        = var.asg.adjustment_type
  cooldown               = var.asg.cooldown1
  autoscaling_group_name = aws_autoscaling_group.asg_ecs.name
}