# Assuming starting point is Java App
# Most of this script comes from: https://github.com/selvasingh/tomcat-on-virtual-machine
source ./deploymentScripts/setup-env-variables-on-azure-template.sh

az login 
az account set --subscription ${SUBSCRIPTION}
az group create --name ${RESOURCE_GROUP} --location ${REGION}
az vm create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${VM_NAME} \
  --image ${VM_IMAGE} \
  --admin-username ${ADMIN_USERNAME} \
  --generate-ssh-keys \
  --public-ip-sku Standard --size standard_d4s_v3

VM_IP_ADDRESS=`az vm show -d -g ${RESOURCE_GROUP} -n ${VM_NAME} --query publicIps -o tsv`

ssh ${ADMIN_USERNAME}@${VM_IP_ADDRESS}

# adding a mix of this file on how to install tomcat https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-9-on-debian-10 

# Update and install Java 
sudo apt update
sudo apt install default-jdk

# Create a Tomcat group and user
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Install tomcat
cd /tmp
sudo apt install curl
curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.74/bin/apache-tomcat-9.0.74.tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1

# Update Permissions
cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat

# Give tomcat9 group read access
sudo chmod -R g+r conf
sudo chmod g+x conf

# Make the tomcat user the owner of the Web apps, work, temp, and logs directories:
sudo chown -R tomcat webapps/ work/ temp/ logs/

