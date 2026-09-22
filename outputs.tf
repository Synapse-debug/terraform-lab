output "aws_instance_public_dns" {
  description = "Public DNS riportato da EC2 (su Floci usa porta host 30000)"
  value       = "http://${replace(aws_instance.ec2.public_dns, "localhost", "10.10.10.11")}:${var.http_port}"
}

output "vpc_id" {
  value = aws_vpc.test.id
}

output "public_subnet_id" {
  value = aws_subnet.test.id
}

output "vero_ip_di_nginx" {
  description = "Vero indirizzo per raggiungere Nginx esposto sulla macchina Floci"
  value       = "http://10.10.10.11:30000"
}