# Specify the provider and access details
provider "aws" {}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-elektronn"
  public_key = "${file("ssh/deployer.pub")}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "elektronn-compute"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_spot_instance_request" "elektronn-compute" {
  spot_type     = "one-time"
  spot_price    = "0.20"
  instance_type = "g2.2xlarge"
  ami           = "${data.aws_ami.ubuntu.id}"
  key_name      = "${aws_key_pair.deployer.key_name}"
  security_groups = ["${aws_security_group.default.name}"]

  tags {
    Name = "elektronn-compute"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    agent        = true
  }
  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
  }
  provisioner "file" {
    source      = "theanorc"
    destination = "/home/ubuntu/.theanorc"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }
}

output "elektronn-compute" {
  value = "${aws_spot_instance_request.elektronn-compute.public_ip}"
}
