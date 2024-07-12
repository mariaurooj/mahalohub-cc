output "ecs_service" {
  value = aws_ecs_service.service.id
}
output "ecs_cluster" {
  value = aws_ecs_cluster.ecs_cluster.id
}