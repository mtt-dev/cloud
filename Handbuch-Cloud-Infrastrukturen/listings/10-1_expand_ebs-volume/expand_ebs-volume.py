#!/bin/env python3

import boto3
import paramiko
import sys
import time
from botocore.exceptions import ClientError

vol_id = sys.argv[1]

myec2 = boto3.resource('ec2')

myvolume = myec2.Volume(vol_id)
vol_size = myvolume.size
vol_az = myvolume.availability_zone

myec2client = boto3.client('ec2')

try:
    response = myec2client.modify_volume(VolumeId=vol_id,
                                         Size=int(vol_size * 1.5))
    print(response)
except ClientError:
    pass

mywaiter = myec2client.get_waiter('volume_available')
mywaiter.wait(VolumeIds=[vol_id])

instances = myec2.create_instances(MinCount=1,
                                   MaxCount=1,
                                   ImageId='ami-0cc0a36f626a4fdf5',
                                   InstanceType='t2.nano',
                                   KeyName="myawskey",
                                   Placement={'AvailabilityZone': vol_az})

instance_id = instances[0].id

mywaiter = myec2client.get_waiter('instance_running')
mywaiter.wait(InstanceIds=[instance_id])

myinstance = myec2.Instance(instance_id)
instance_ipv4 = myinstance.public_ip_address

response = myvolume.attach_to_instance(Device="/dev/sdd",
                                       InstanceId=instance_id)

mysshclient = paramiko.SSHClient()
mysshclient.set_missing_host_key_policy(paramiko.AutoAddPolicy())

time.sleep(60)
mysshclient.connect(instance_ipv4,
                    username="ubuntu",
                    key_filename="/home/vagrant/.ssh/myawskey")

commands = ['sudo growpart /dev/xvdd 1',
            'sudo e2fsck -fy /dev/xvdd1',
            'sudo resize2fs /dev/xvdd1']

for command in commands:
    stdin, stdout, stderr = mysshclient.exec_command(command)
    print(stderr.readlines())
    print(stdout.readlines())

mysshclient.close()

response = myvolume.detach_from_instance(Device="/dev/sdd",
                                         InstanceId=instance_id)

myinstance.terminate()
print("Have a nice day!")
