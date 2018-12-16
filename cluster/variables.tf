# Labeling to find in console
variable "name" {
  default = "nifi"
}

variable "node_count" {
  default = "3"
}

variable "aws_keypair" {}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type to use"
}

# ["${aws_security_group.cluster.id}"]
variable "security_group_ids" {
  type = "list"
}

# aws_subnet.private.*.id
variable "subnet_ids" {
  type = "list"
}

variable "ami" {
  default = "ami-cfe4b2b0"
}

variable "bastion_username" {
  default = "ec2-user"
}

# "${file(var.bastion_private_key)}" 
variable "bastion_private_key" {}

variable "bastion_public_ip" {}

# "${aws_route53_zone.private.id}"
variable "private_zone_id" {}
