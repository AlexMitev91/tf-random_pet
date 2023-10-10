terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "random_pet" "server" {
  keepers = {
    ami_id = data.aws_ami.ubuntu.id
  }
}

resource "aws_instance" "web" {
  ami           = random_pet.server.keepers.ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "web-server-${random_pet.server.id}"
  }
}
output "instance_ami" {
  description = "Show the *keepers* AMI value from the random pet provider"
  value       = random_pet.server.keepers.ami_id
}

output "instance_name" {
  description = "Show the name of the instance and the pet name generated"
  value       = aws_instance.web.tags
}