# Step 10 - Add output variables


# output "web_eip" {
#   value = aws_eip.static_eip.public_ip
# }

output "webserver_vm1_subnet1"{
  
value = aws_instance.public_webservers_vm1.public_ip
}

output "public_ip_for_bastion" {
  value = aws_instance.bastion_host.public_ip
}


output "public_webservers_vm3_vm4" {
  value = aws_instance.public_webservers_vm3_vm4[*].public_ip
}

output "web_server_private" {
  value = aws_instance.web_server_private[*].private_ip
}



