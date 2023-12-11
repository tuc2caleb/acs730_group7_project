# Add output variables
output "subnet_id" {
  value = aws_subnet.public_subnet[*].id
}
# Add output variables
output "pri_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}
output "vpc_id" {
  value = aws_vpc.main.id
}
