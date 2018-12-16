# Create a standard VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  instance_tenancy     = "${var.tenancy}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}/vpc"
  }
}

# Fetch AZs in the current region. We will need at least 2 AZs in order to assign an ALB
# to the ECS Fargate cluster
data "aws_availability_zones" "available" {}

# Attach an IGW - This is used to assign an IP to the cluster in order for ingress activity and
# to create a NAT gateway so internet traffic can leave the private subnet.  We need to connect
# to the internet from the private subnet to pull down docker containers from the public registry
# We need an ALB to be part of the solution with a consistent IP address. Fargate re-assigns a new
# IP for any container that restarts (if configured to be public facing)
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}/default"
  }
}

# Create a DMZ subnet
# Public facing subnet for:
# - Internet gateway
# - Application load balancer
resource "aws_subnet" "dmz" {
  count                   = 2
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, var.az_count + count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "${var.name}/dmz"
  }
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity for
# # docker pulls and API calls and such
# resource "aws_eip" "gw" {
#   count      = "${var.az_count}"
#   vpc        = true
#   depends_on = ["aws_internet_gateway.gw"]
# }

# resource "aws_nat_gateway" "gw" {
#   count         = "${var.az_count}"
#   subnet_id     = "${element(aws_subnet.dmz.*.id, count.index)}"
#   allocation_id = "${element(aws_eip.gw.*.id, count.index)}"
# }

# Create a new route table for the private subnets
# And make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = "${element(aws_nat_gateway.gw.*.id, count.index)}"
  # }
}

# Create a Private subnet
resource "aws_subnet" "private" {
  count             = "${var.az_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "${var.name}/private"
  }
}

# Associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# Define a route table with IGW for the DMZ
resource "aws_route_table" "dmz" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "${var.name}/dmz"
  }
}

resource "aws_route_table_association" "dmz" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.dmz.*.id, count.index)}"
}
