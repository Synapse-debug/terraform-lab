output "aws_instance_public_dns" {
  value = aws_instance.ec2.public_dns
}

output "vpc_id" {
  value = aws_vpc.test.id
}

output "public_subnet_id" {
  value = aws_subnet.test.id
}


    