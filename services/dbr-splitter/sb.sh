#!/bin/bash

workdir="/opt/splitbill"
cd $workdir

#
# Copy the splitbill executable and config from S3
#
aws s3 cp --region ${region} s3://${bucket}/splitbill-config.yml config.yml
aws s3 cp --region ${region} s3://${bucket}/splitbill .
chmod +x splitbill

#
# don't allow the file to grow over 10m and only keep one backup
#
max=10000000
size=$(wc -c < splitbill.log)
if [ $size -ge $max ]; then
    mv splitbill.log splitbill.log.1
fi

./splitbill -s >> splitbill.log 2>&1

#
# Stop the instance after sleeping for 5 minutes to give
# some time to cloudwatch metrics pushing
# Also give us enough run-time to rerun Terraform and do
# some debugging if necessary.
#
sleep 300
sudo shutdown -h now
