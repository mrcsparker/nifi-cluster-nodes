# Security group definitions

resource "aws_security_group" "dmz" {
  name   = "${var.name}/dmz"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}/dmz"
  }
}

resource "aws_security_group" "bastion" {
  name   = "${var.name}/bastion"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}/bastion"
  }
}

resource "aws_security_group" "cluster" {
  name   = "${var.name}/cluster"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}/cluster"
  }
}

# Bastion access
resource "aws_security_group_rule" "incoming_public_to_bastion" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = [
    "${var.bastion_whitelist}",
  ]

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "outgoing_bastion_to_cluster" {
  type      = "egress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.bastion.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
}

resource "aws_security_group_rule" "outgoing_bastion_to_world" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "incoming_bastion_to_cluster" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "cluster_to_world" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.cluster.id}"
}
