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

# Install Docker-Compose - requires gcc to install
sudo yum install -y gcc
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

cd ..
unzip /tmp/docker-ice.zip
cd docker-ice

# Move Vouch config if present
if [ -f /tmp/config.yml ]; then
    mkdir -p vouch/assets/config
    mkdir -p vouch/assets/data
    mv /tmp/config.yml vouch/assets/config
    mv /tmp/default.conf nginx-vouch/assets
else
    # Move Nginx config file if present
    if [ -f /tmp/nginx.conf ]; then
        mv /tmp/nginx.conf nginx-ldap/assets
    fi
fi

# Set up ICE as an init.d service and start it.
sudo mv /tmp/ice /etc/init.d
sudo chmod +x /etc/init.d/ice
sudo chkconfig --add ice
sudo service ice start

