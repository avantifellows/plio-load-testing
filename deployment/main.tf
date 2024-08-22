# main.tf

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ubuntu_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Ubuntu-20.04-Instance"
  }

  # key_name = "AvantiFellows"
  key_name      = var.key_name

  # user_data = <<-EOF
  #             #!/bin/bash

  #             K6_TAR_LINK=https://github.com/grafana/k6/releases/download/v0.45.0/k6-v0.45.0-linux-arm64.tar.gz
  #             curl -OL $K6_TAR_LINK
  #             tar -xzf k6-v0.45.0-linux-arm64.tar.gz
  #             sudo mv k6-v0.45.0-linux-arm64/k6 /usr/local/bin/k6
  #             rm -rf k6-v0.45.0-linux-arm64*
  #             sudo apt-get update
  #             sudo apt-get upgrade -y
  #             sudo apt-get install -y gits

  #             # OS fine tuning
  #             echo "net.ipv4.ip_local_port_range = 1024 65535" | sudo tee -a /etc/sysctl.conf
  #             echo "net.ipv4.tcp_tw_reuse = 1" | sudo tee -a /etc/sysctl.conf
  #             echo "net.ipv4.tcp_timestamps = 1" | sudo tee -a /etc/sysctl.conf
  #             sudo sysctl -p

  #             # Increase open file limit
  #             echo "* soft nofile 1000000" | sudo tee -a /etc/security/limits.conf
  #             echo "* hard nofile 1000000" | sudo tee -a /etc/security/limits.conf

  #             # clone repo
  #             git clone https://github.com/avantifellows/plio-load-testing
  #             EOF

  user_data = <<-EOF
              #!/bin/bash

              # Redirect stdout and stderr to a log file
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "Starting user data script execution"

              K6_TAR_LINK=https://github.com/grafana/k6/releases/download/v0.45.0/k6-v0.45.0-linux-arm64.tar.gz
              echo "Downloading K6"
              curl -OL $K6_TAR_LINK
              echo "Extracting K6"
              tar -xzf k6-v0.45.0-linux-arm64.tar.gz
              echo "Moving K6 to /usr/local/bin"
              sudo mv k6-v0.45.0-linux-arm64/k6 /usr/local/bin/k6
              echo "Cleaning up K6 installation files"
              rm -rf k6-v0.45.0-linux-arm64*
              
              echo "Updating and upgrading packages"
              sudo apt-get update
              sudo apt-get upgrade -y
              echo "Installing git"
              sudo apt-get install -y git

              echo "OS fine tuning"
              echo "net.ipv4.ip_local_port_range = 1024 65535" | sudo tee -a /etc/sysctl.conf
              echo "net.ipv4.tcp_tw_reuse = 1" | sudo tee -a /etc/sysctl.conf
              echo "net.ipv4.tcp_timestamps = 1" | sudo tee -a /etc/sysctl.conf
              sudo sysctl -p

              echo "Increasing open file limit"
              echo "* soft nofile 1000000" | sudo tee -a /etc/security/limits.conf
              echo "* hard nofile 1000000" | sudo tee -a /etc/security/limits.conf

              echo "Cloning repository"
              cd /home/ubuntu
              git clone https://github.com/avantifellows/plio-load-testing
              if [ $? -eq 0 ]; then
                echo "Repository cloned successfully"
              else
                echo "Failed to clone repository"
              fi

              echo "User data script completed"
              EOF

  # Ensure the instance has an associated public IP
  associate_public_ip_address = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
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

  tags = {
    Name = "allow_ssh"
  }
}

# Output the public IP of the instance
output "ssh_connection_string" {
  description = "SSH connection string for the EC2 instance"
  value       = "ssh -i \"${var.key_name}.pem\" ubuntu@${aws_instance.ubuntu_instance.public_dns}"
}

# variables.tf

variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "ap-south-1"  # Change this to your preferred region
}

variable "ami_id" {
  description = "The AMI ID for Ubuntu Server 24.04 LTS arm64"
  default     = "ami-0000791bad666add5"  # This is an example AMI ID, please verify for your region
}

variable "instance_type" {
  description = "The instance type"
  default     = "t4g.large"
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  default     = "AvantiFellows"  # Change this to match your key pair name
}
