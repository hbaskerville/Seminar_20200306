variable "access_key" {}
variable "secret_key" {}

variable "vault_addr" {}
variable "login_approle_role_id" {}
variable "login_approle_secret_id" {}

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
  default = "ami-0392dd50db9931d28"
}

variable "web_instance_name" {
  default = "TFtest"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Key/value tags to assign to all AWS resources"
}

variable "public_key" {}
