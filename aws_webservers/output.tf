# # Step 10 - Add output variables
# output "public_ip" {
#   value = aws_instance.bastion_host.public_ip
# }

# output "web_eip" {
#   value = aws_eip.static_eip.public_ip
# }

# Step 10 - Add output variables
output "public_ip_for_bastion" {
  value = module.aws_webserver_m.public_ip_for_bastion
}

# output "web_eip" {
#   value = module.aws_webserver_m.aws_eip.static_eip.public_ip
# }

output "webserver_vm1_subnet1"{
  
//value = aws_instance.public_webservers_vm1.public_ip
value = module.aws_webserver_m.webserver_vm1_subnet1
}


///


output "public_ip_webservers_vm3_vm4" {
 // value = aws_instance.public_webservers_vm3_vm4[*].public_ip
  value = module.aws_webserver_m.public_webservers_vm3_vm4
}


output "private_ip_webservers_vm5_vm6" {
  //value = aws_instance.web_server_private[*].public_ip
   value = module.aws_webserver_m.web_server_private
}

# output "public_ip" {
#   value = aws_instance.bastion_host.public_ip
# }

# output "public_webservers_vm3_vm4"{
  
# value = aws_instance.public_webservers_vm3_vm4.public_ip
# }



# output "web_server_private"{
  
# value = aws_instance.web_server_private.public_ip
# }



