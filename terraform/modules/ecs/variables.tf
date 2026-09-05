variable "ecr_image_url" {
  type = string
}
variable "execution_role_arn" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "ecs_tasks_sg_id" {
  type = string
}
variable "target_group_arn" {
  type = string
}