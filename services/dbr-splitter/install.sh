#!/bin/bash

# do all work in the /opt directory
workdir="/opt"
cd $workdir

# Make a splitbill directory
sudo mkdir splitbill
sudo chown ec2-user splitbill
chgrp ec2-user splitbill

cd splitbill

mv /tmp/sb.sh .
chmod +x sb.sh

#
# Add startup to rc.local so we restart the service on reboot
#
sudo bash -c "echo /bin/bash /opt/splitbill/sb.sh\& >> /etc/rc.local"

#
# Install the CloudWatch Logs Agent
#
sudo yum update -y
sudo yum install -y awslogs
cd /etc/awslogs
#
# Set the region in the awscli.conf file
#
sudo mv awscli.conf awscli.orig.conf
sudo bash -c "cat awscli.orig.conf | sed -e \"s/^region = .*/region = ${region}/\" > awscli.conf"
#
# Copy the logs configuration
#
sudo mv /tmp/awslogs.conf .
#
# Start the Agent
#
sudo chkconfig awslogs on
sudo service awslogs start
#
# shutdown
#
sudo shutdown -h now

