resource "aws_instance" "bastion" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${aws_subnet.dmz.0.id}"

  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  tags {
    Name = "${var.name}/bastion"
  }

  key_name = "${aws_key_pair.default.key_name}"
}
