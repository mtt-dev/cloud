#!/usr/bin/env python3
import hcloud
import json
import os

number_of_workers = 3

token = os.environ['HCLOUD_TOKEN']
client = hcloud.Client(token=token)

type = hcloud.server_types.domain.ServerType(name='cx21')
image = hcloud.images.domain.Image(name='ubuntu-16.04')
keys = [hcloud.ssh_keys.domain.SSHKey(name='myhetznerkey')]
location = hcloud.datacenters.domain.Datacenter(name='nbg1')

def create_server(name):
    response = client.servers.create(name=name,
                                     server_type=type,
                                     image=image,
                                     location=location,
                                     ssh_keys=keys)
    return response.server

def get_servers():
    servers = client.servers.get_all()
    if not servers:
        return False
    elif len(servers) == number_of_workers+1:
        return servers

if get_servers() is False:
    for node in range(1, number_of_workers+1):
        node_name = 'worker' + str(node)
        worker = create_server(node_name)
    master = create_server('master1')

servers = get_servers()
inventory = {}
hosts = {}
nodes = []
for server in servers:
    if 'master' in server.name:
        nodes.append(server.public_net.ipv4.ip)
        hosts['hosts']=nodes
        inventory['master']=hosts
hosts = {}
nodes = []
for server in servers:
    if 'worker' in server.name:
        nodes.append(server.public_net.ipv4.ip)
        hosts['hosts']=nodes
        inventory['worker']=hosts
print(json.dumps(inventory))
