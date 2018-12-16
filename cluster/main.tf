resource "aws_instance" "nifi_node" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  count                  = "${var.node_count}"
  vpc_security_group_ids = ["${var.security_group_ids}"]
  user_data              = "${data.template_file.user_data.rendered}"
  subnet_id              = "${element(var.subnet_ids, count.index%var.node_count)}"
  key_name               = "${var.aws_keypair}"

  tags {
    Name = "${var.name}/Nifi Cluster Node"
  }

  # Make sure directory is in place before copying the entire directory of 
  # configurations
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /tmp/nifi/conf",
      "sudo chown -R ec2-user /tmp/nifi",
    ]

    connection {
      agent               = false
      type                = "ssh"
      user                = "${var.bastion_username}"
      private_key         = "${var.bastion_private_key}"
      bastion_host        = "${var.bastion_public_ip}"
      bastion_private_key = "${var.bastion_private_key}"
      bastion_user        = "${var.bastion_username}"
    }
  }

  # Copy the conf folder of configurations to a temp directory
  provisioner "file" {
    source      = "${path.module}/conf/"
    destination = "/tmp/nifi/conf"

    connection {
      agent               = false
      type                = "ssh"
      user                = "${var.bastion_username}"
      private_key         = "${var.bastion_private_key}"
      bastion_host        = "${var.bastion_public_ip}"
      bastion_private_key = "${var.bastion_private_key}"
      bastion_user        = "${var.bastion_username}"
    }
  }

  # copy the script to be used by null_resource to setup the cluster
  provisioner "file" {
    source      = "${path.module}/templates/setup_cluster.sh"
    destination = "/tmp/setup_cluster.sh"

    connection {
      agent               = false
      type                = "ssh"
      user                = "${var.bastion_username}"
      private_key         = "${var.bastion_private_key}"
      bastion_host        = "${var.bastion_public_ip}"
      bastion_private_key = "${var.bastion_private_key}"
      bastion_user        = "${var.bastion_username}"
    }
  }

  # Run script to setup the nifi cluster mount points
  provisioner "remote-exec" {
    inline = [
      "chmod 755 /tmp/setup_cluster.sh",
      "sudo /tmp/setup_cluster.sh",
    ]

    connection {
      agent               = false
      type                = "ssh"
      user                = "${var.bastion_username}"
      private_key         = "${var.bastion_private_key}"
      bastion_host        = "${var.bastion_public_ip}"
      bastion_private_key = "${var.bastion_private_key}"
      bastion_user        = "${var.bastion_username}"
    }
  }
}

# User data template to setup permissions on the server
data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    cluster = "${var.name}"
  }
}

resource "aws_route53_record" "nifi" {
  count   = "${var.node_count}"
  zone_id = "${var.private_zone_id}"
  name    = "nifi-${count.index}"
  type    = "A"
  ttl     = "300"

  records = ["${element(aws_instance.nifi_node.*.private_ip, count.index)}"]
}
