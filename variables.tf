# Labeling to find in console
variable "name" {
  default = "nifi"
}

# VPC vars
variable "tenancy" {
  default = "default"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "aws_region" {
  default = "us-east-1"
}

# Personalization variables
variable "whitelist" {}

variable "bastion_whitelist" {}

variable "bastion_username" {
  default = "ec2-user"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "aws_keypair" {
  default = "poc"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type to use"
}

variable "ami" {
  default = "ami-cfe4b2b0"
}

variable "nifi_base_dir" {
  default = "/opt/nifi"
}

variable "nifi_gid" {
  default = "1000"
}

variable "nifi_uid" {
  default = "1000"
}
