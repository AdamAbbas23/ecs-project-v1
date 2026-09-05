variable "vpc_cidr" {
  description = "cidr for the vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "cidr for private subnets"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = list(string)
}

variable "private_subnet_cidr" {
  description = "cidr for private subnets"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  type = list(string)
}

variable "availability_zone" {
  description = "az for subnets"
  default = ["eu-west-2a", "eu-west-2b"]
  type = list(string)
}