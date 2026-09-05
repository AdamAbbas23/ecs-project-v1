variable "public_subnet_cidr" {
  description = "cidr for private subnets"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "cidr for private subnets"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  type = list(string)
}
variable "project_name" {
  type = string
  default = "ecs-app"
}
variable "domain_name" {
  type = string
}
variable "zone_id" {
  type = string
}