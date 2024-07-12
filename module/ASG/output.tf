output "cpu_scale_up" {
  value = aws_autoscaling_policy.cpu_scale_up.arn
}
output "cpu_scale_down" {
  value = aws_autoscaling_policy.cpu_scale_down.arn
}