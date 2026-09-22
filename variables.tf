variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "vpc_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "http_port" {
  type    = number
}

variable "ec2_instance_type" {
  type    = string
}

variable "company_name" {
  type = string
  default = "Globamantics"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "billing_code" {
  type = string
}
  