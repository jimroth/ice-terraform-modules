import boto3
import os

# Enter the region your instances are in, e.g. 'us-east-1'
az = os.environ['az']
region = az[:-1]

# Enter your instances here: ex. ['X-XXXXXXXX', 'X-XXXXXXXX']
instances = [os.environ['id']]

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=region)
    ec2.start_instances(InstanceIds=instances)
    print 'started your instances: ' + str(instances)
