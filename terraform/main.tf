#terraform {
#  required_version = ">= 0.8, < 0.9"
#}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

# TODO: use a west coast region.
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  # AMI built by running `packer terraform/ami.js`
  ami           = "ami-08e46d157b9c6bfb2"
  instance_type = "t2.micro"

  # Needed for the sake of ssh
  key_name = "DeveloperKeyPair"

  # Use the security group below to expose port 8080.
  vpc_security_group_ids = ["${aws_security_group.instance.id}", "${aws_security_group.ssh.id}"]

  # Use busybox to return a very simple http response
  # TODO: pull down the docker container.
  # Then login and start it.
  user_data = <<-EOF
              #!/bin/bash
              DOCKER_LOGIN="sudo "`aws ecr get-login`
              $(echo $DOCKER_LOGIN)
              sudo docker pull 697071018446.dkr.ecr.us-east-1.amazonaws.com/ktor-deployed-attwell-1
              sudo docker run -p 8080:8080 --rm 697071018446.dkr.ecr.us-east-1.amazonaws.com/ktor-deployed-attwell-1
              EOF

  tags {
    Name = "terraform-example"
  }
}

# SEE https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#docker-basics-create-image

# By default AWS does not allow any incoming or outgoing traffic from
# and EC2 instance. To allow EC2 traffic on port 8080, we need a security
# group.
# Specifying security group is not enough if we also have
# a very old AWS account. In this case, just create a new
# account.
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Expose SSH so that we can mess around with this instance
# in production and try things out.
resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "(Proxy) Allow SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
