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

# Update and install Java/Maven
sudo apt update
sudo apt install default-jdk
sudo apt install maven

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

# ==== Create a systemd Service File
# find JAVA_HOME
sudo update-java-alternatives -l
# java-1.11.0-openjdk-amd64      1111       /usr/lib/jvm/java-1.11.0-openjdk-amd64

# Open a file called tomcat9.service in the /etc/systemd/system
sudo nano /etc/systemd/system/tomcat.service


# Add the following config to the file above: 

[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target


# Run the following to reload the systemd Daemon: 
sudo systemctl daemon-reload

# start tomcat service and get status: 
sudo systemctl start tomcat
sudo systemctl status tomcat

# Enable the service file so that Tomcat automatically starts at boot:
sudo systemctl enable tomcat 

# Run the following to open port 8080 on the vm to test if tomcat is working
az vm open-port --port 8080 --resource-group ${RESOURCE_GROUP} --name ${VM_NAME} --priority 1100

# GoTO http://[$VM_IP_ADDRESS]:8080/ to confirm that it's working :D :D :D 
# Now we need to create a user with access to Tomcat Manager and Tools: by adding the following to 

# Configure Tomcat 9
# Configure management user
sudo nano /opt/tomcat/conf/tomcat-users.xml

# add the following to the inside of the <tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <role rolename="manager-script"/>
    <user username="manager" password="SuperS3cr3t" roles="manager-gui,admin-gui,manager-script"/>

# Now we need to allow manager and host manager app connection coming from anywhere instead of just the server
sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml 

# Here you want to comment out the following section by adding the <!-- -->
<!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->

#Comment out the same section here as well: 
sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml

# Restart tomcat to make sure it's all working correctly
sudo systemctl restart tomcat

sudo nano /usr/share/maven/conf/settings.xml
# Go to the <servers> </servers section and add the following: 
    <server>
        <id>maven-tomcat-war-deployment-server</id> 
        <username>manager</username> 
        <password>SuperS3cr3t</password>
    </server>



#### DO WE NEED THESE STEPS?????
# Run the following code locally in the Java-Demo-Project folder to get a WAR file: 
jar -cvf Java-demo.war *

# Need to get the war file that we made locally. I've added it to the repo so I'm just going to pull the entire repo down
wget https://github.com/dasha91/JavaDemoApp/blob/main/Java-Demo-Project/Java-demo.war
