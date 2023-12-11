#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
myip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
hostname=$(hostname)
environment="Dev"

echo "<h1>Welcome to $environment environment!</h1><br>
      <h1>Final Group7 Project: Two-Tier web application automation with Terraform, Ansible and GitHub Actions</h1>
      <p>This is VM with hostname: $hostname and IP: $myip.</p>
     
      </font></p><ul><li>Rabia Khalid</li><li>Babatunde Seyi Oyeyemi</li><li>Caleb Udoh Okon</li><li>Ismael Adem</li><li>Mohammad Rasoulzadeh</li></ul>
      <p>Built by Terraform!</p>">/var/www/html/index.html
      
sudo systemctl start httpd
sudo systemctl enable httpd



# #!/bin/bash  <p>Configured by: $your_name</p> your_name="Rabia Khalid"
# yum -y update
# yum -y install httpd
# myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
# echo "<h1>Welcome to ACS730 Assignment Dev Deployment My private IP for webserver vm is  $myip</h1><br>Built by Terraform!"  >  /var/www/html/index.html
# sudo systemctl start httpd
# sudo systemctl enable httpd


# #!/bin/bash
#     sudo yum -y update
#     sudo yum -y install httpd
#     myip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
#     environment="Dev"
#     your_name="Rabia Khalid"
#     echo "<h1>Welcome to $environment environment!</h1><br>
#           <p>This is VM $((count.index + 1)) with IP: $myip.</p>
#           <p>Configured by: $your_name</p>
#           <p>Built by Terraform!</p>" > /var/www/html/index.html
#     sudo systemctl start httpd
#     sudo systemctl enable httpd


# #!/bin/bash
# sudo yum -y update
# sudo yum -y install httpd

# myip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
# environment="Dev"
# your_name="Rabia Khalid"

# html_content="<h1>Welcome to $environment environment!</h1><br>
#               <p>This is VM\$((count.index + 1)) with IP: $myip.</p>
#               <p>Configured by: $your_name</p>
#               <p>Built by Terraform!</p>"

# echo "$html_content" > /var/www/html/index.html

#   sudo systemctl start httpd
#   sudo systemctl enable httpd


# #!/bin/bash
# sudo yum -y update
# sudo yum -y install httpd
# myip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
# environment="Dev"
# your_name="Rabia Khalid"
# vm_index=$(hostname | grep -o '[0-9]\+')
# echo "<h1>Welcome to $environment environment!</h1><br>
#       <p>This is VM $vm_index with IP: $myip.</p>
#       <p>Configured by: $your_name</p>
#       <p>Built by Terraform!</p>" > /var/www/html/index.html
# sudo systemctl start httpd
# sudo systemctl enable httpd
