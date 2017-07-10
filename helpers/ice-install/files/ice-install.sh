#!/bin/bash

# do all work in the /opt directory
workdir="/opt"
cd $workdir

# install Docker
# http://www.ybrikman.com/writing/2015/11/11/running-docker-aws-ground-up/
#
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker-Compose
sudo pip install docker-compose

# Install Git so we can pull down stuff from GitHub
sudo yum install -y git

# Get docker-ice
sudo mkdir docker-ice
sudo chown ec2-user docker-ice
chgrp ec2-user docker-ice

cd docker-ice
git init
git pull https://github.com/jimroth/docker-ice.git

# Configure docker-ice
# Remove key parameters (we're using roles)
grep -v Key docker-compose-template.yml > docker-compose.yml

# Move the configuration files provisioned to /tmp
mv /tmp/docker-compose.yml .
mv /tmp/ice.properties ice/assets

# Move Nginx config file if present
if [ -f /tmp/nginx.conf ]; then
    mv /tmp/nginx.conf nginx-ldap/assets
fi
# Move Nginx SSL credentials if present
if [ -f /tmp/ice.key ]; then
    mkdir -p nginx-ldap/assets/ssl
    mv /tmp/ice.key nginx-ldap/assets/ssl/ice.key
fi
if [ -f /tmp/ice.crt ]; then
    mkdir -p nginx-ldap/assets/ssl
    mv /tmp/ice.crt nginx-ldap/assets/ssl/ice.crt
fi

# Set up ICE as an init.d service and start it.
sudo mv /tmp/ice /etc/init.d
sudo chmod +x /etc/init.d/ice
sudo chkconfig --add ice
sudo service ice start

