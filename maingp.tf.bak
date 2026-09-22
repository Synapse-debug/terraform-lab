terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

# Endpoint Floci (sulla VM Floci della rete privata)
provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://10.10.10.11:4566"
    iam = "http://10.10.10.11:4566"
    sts = "http://10.10.10.11:4566"
    s3  = "http://10.10.10.11:4566"
  }
}

# Security group: apre HTTP e SSH (Floci pubblica la porta 80 su una porta host)
resource "aws_security_group" "web" {
  name        = "nginx-web"
  description = "Allow HTTP and SSH"

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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
    Name = "nginx-web"
  }
}

# EC2 con nginx installato e avviato via user_data
resource "aws_instance" "nginx" {
  # AMI emulata da Floci (Ubuntu 24.04, variante amd64 per t3.micro)
  ami                    = "ami-ubuntu2404-amd64"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    set -x
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
    # Floci usa la porta 80 su 169.254.169.254 per l'IMDS: nginx va su 8080
    sed -i 's/listen 80 default_server;/listen 8080 default_server;/' /etc/nginx/sites-available/default
    sed -i 's/listen \[::\]:80 default_server;/listen [::]:8080 default_server;/' /etc/nginx/sites-available/default
    echo "<h1>Hello from Terraform + nginx su Floci</h1>" > /var/www/html/index.html
    nginx || true
    sleep 2
    (ss -ltnp 2>/dev/null || netstat -ltnp 2>/dev/null) | grep ':8080' || true
  EOF

  tags = {
    Name = "nginx"
  }
}

output "instance_id" {
  value       = aws_instance.nginx.id
  description = "ID dell'istanza EC2 emulata"
}

# NB: in Floci l'IP riportato e' quello del container, spesso 127.0.0.1.
# Per raggiungere nginx usare la porta host pubblicata sulla VM Floci:
#   docker logs floci | grep "Published EC2 instance"
#   -> http://10.10.10.11:<host-port>
output "instance_public_ip" {
  value       = aws_instance.nginx.public_ip
  description = "IP riportato da Floci (non usare per l'accesso: usare la porta host)"
}

output "security_group_id" {
  value       = aws_security_group.web.id
  description = "ID del security group"
}
