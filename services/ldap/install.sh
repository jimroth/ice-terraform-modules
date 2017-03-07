#!/bin/bash

# do all work in the /opt directory
workdir="/opt"
cd $workdir

# Make an ldap directory
sudo mkdir ldap
sudo chown ec2-user ldap
chgrp ec2-user ldap

cd ldap

wget https://s3-ap-southeast-2.amazonaws.com/aws-iam-apacheds/apacheds-0.2.2.zip
unzip apacheds-0.2.2.zip
rm apacheds-0.2.2.zip

# Change config to use IAM Account Passwords rather than IAM Secret Access Keys
echo "validator=iam_password" > iam_ldap.conf
sudo mv iam_ldap.conf /etc

sudo yum install -y openldap-clients

#
# Add startup to rc.local so we restart the service on reboot
#
#sudo bash -c "echo /bin/bash /opt/ldap/apacheds/bin/apacheds.sh default start\& >> /etc/rc.local"

#
# Start up the service in the background
#
#/bin/bash apacheds/bin/apacheds.sh default start

# Set up LDAP as an init.d service and start it.
sudo mv /tmp/ldap /etc/init.d
sudo chmod +x /etc/init.d/ldap
sudo chkconfig --add ldap

# Use init to start the service so it isn't associated with our ssh connection
sudo telinit 5
# takes a while to get up and running the first time.
sleep 20

#
# Change the password on the admin user
#
ldappasswd -H ldap://localhost:10389 -x -D 'uid=${ldap_user},ou=system' -w secret -a secret -s '${ldap_password}'

#
# You can test the installation with the following command
#
# ldapsearch -H ldap://localhost:10389 -D "uid=<ldap_user>,ou=system" -x -w <ldap_password> -b "dc=iam,dc=aws,dc=org" "(objectclass=posixaccount)"
#
