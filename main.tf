terraform {
  required_version = ">= 0.11.7"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_key_pair" "default" {
  key_name   = "${var.aws_keypair}"
  public_key = "${file(var.public_key_path)}"
}

# Note: This is not to setup for cluster configuration. Cluster host will be
# Assigned from the container launch and configured through env variables.  
# This is to help with administration and ssh'ing into the box
resource "aws_route53_zone" "private" {
  name = "cluster"

  vpc {
    vpc_id = "${aws_vpc.vpc.id}"
  }
}

module "nifi-cluster" {
  source              = "./cluster"
  name                = "${var.name}"
  node_count          = "${var.az_count}"
  aws_keypair         = "${var.aws_keypair}"
  instance_type       = "t2.micro"
  security_group_ids  = ["${aws_security_group.cluster.id}"]
  subnet_ids          = "${aws_subnet.private.*.id}"
  bastion_private_key = "${file(var.private_key_path)}"
  bastion_public_ip   = "${aws_instance.bastion.public_ip}"
  private_zone_id     = "${aws_route53_zone.private.id}"
}
