#!/bin/bash
#
# Install AWS CloudWatch metrics scripts on an EC2 Instance

# do all work in the /opt directory
workdir="/opt"
cd $workdir

sudo yum update -y
yum_result=$?

if [ "$yum_result" -ne 0 ] ; then
	echo "Yum update failed. Stopping"
	exit "$yum_result"
fi

# install perl modules needed by the AWS scripts
sudo yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https
yum_result=$?

if [ "$yum_result" -ne 0 ] ; then
	echo "Yum install of PERL modules failed. Stopping"
	exit "$yum_result"
fi

# download the AWS scripts
sudo curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
curl_result=$?

if [ "$curl_result" -ne 0 ] ; then
	echo "Error downloading AWS CloudWatch scripts. Stopping"
	exit "$curl_result"
fi


# install the scripts
sudo unzip CloudWatchMonitoringScripts-1.2.1.zip
unzip_result=$?
if [ "$unzip_result" -ne 0 ] ; then
	echo "Error unzipping AWS CloudWatch scripts. Stopping"
	exit "$unzip_result"
fi

sudo rm CloudWatchMonitoringScripts-1.2.1.zip

# add the command to crontab to push metrics every 5 minutes
entry="*/5 * * * * $workdir/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --from-cron"
(crontab -l ; echo "$entry") | crontab -

crontab_result=$?
if [ "$crontab_result" -ne 0 ] ; then
	echo "Error setting crontab for AWS CloudWatch scripts. Stopping"
	exit "$crontab_result"
fi

