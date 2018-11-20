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
  # Standard AMI with Ubuntu installed
  ami           = "ami-40d28157"
  instance_type = "t2.micro"

  # Use the security group below to expose port 8080.
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  # Use busybox to return a very simple http response
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  tags {
    Name = "terraform-example"
  }
}

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
