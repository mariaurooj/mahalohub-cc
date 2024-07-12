resource "aws_cloudwatch_log_group" "logs" {
  name = "/ecs/dev/mahalohub/closedcaptioning"
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "ecs-logs/${var.environment}-${var.prefix}-closedcaptioning"
  log_group_name = aws_cloudwatch_log_group.logs.name
}