output "target_group_arn" {
  value = aws_lb_target_group.ecs-tg.arn
}
output "alb_dns_name" {
  value = aws_lb.ecs-alb.dns_name
}
output "alb_zone_id" {
  value = aws_lb.ecs-alb.zone_id
}