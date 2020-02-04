variable "access_key" {}
variable "secret_key" {}

variable "web_instance_count" {
  default = 1
}


variable "region" {
  default = "ap-northeast-1"
}

variable "web_instance_type" {
  default = "t2.micro"
}


variable "availability_zones" {
  type    = "list"
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "pubic_subnets_cidr" {
  type    = "list"
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}

variable "public_subnet_name" {
  default = "public"
}

variable "ami" {
  default = "ami-06d9ad3f86032262d"
}

variable "web_instance_name" {
  default = "TFtest"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Key/value tags to assign to all AWS resources"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}
