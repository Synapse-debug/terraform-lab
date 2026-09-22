# =============================================
# Primo test: risorse AWS locali via Floci
# =============================================


data "aws_ssm_parameter" "nome_a_scelta" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_vpc" "test" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
}

resource "aws_internet_gateway" "test" {
  vpc_id = aws_vpc.test.id
}

resource "aws_subnet" "test" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = var.vpc_subnet_cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

resource "aws_route_table" "test" {
  vpc_id = aws_vpc.test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test.id
  }
}
resource "aws_route_table_association" "test" {
  subnet_id      = aws_subnet.test.id
  route_table_id = aws_route_table.test.id
}

resource "aws_security_group" "test" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.test.id
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
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

resource "aws_instance" "ec2" {
  ami                    = data.aws_ssm_parameter.nome_a_scelta.value
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.test.id
  vpc_security_group_ids = [aws_security_group.test.id]
  user_data              = <<-EOF
#! /bin/bash
amazon-linux-extras install -y nginx1
sed -i 's/listen       \[::\]:80;/#listen \[::\]:80;/' /etc/nginx/nginx.conf
sed -i 's/listen       80;/listen 10.0.0.10:80;/' /etc/nginx/nginx.conf
nginx
rm -f /usr/share/nginx/html/index.html
echo '<h1>Welcome to the website! Have a pizza! 🍕</h1>' > /usr/share/nginx/html/index.html
EOF
}








