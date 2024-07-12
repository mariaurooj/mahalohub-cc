output "aws_alb" {
  value = aws_lb.aws_alb.arn
}
output "aws_alb_target_group" {
  value = aws_lb_target_group.targetgroup.arn
}
output "aws_lb_target_group" {
  value = aws_lb_target_group.monitoringtargetgroup.arn
}
