#!/bin/bash

# Docker installieren

curl -sS https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce

# Swapping generell deaktivieren

echo "0" > /proc/sys/vm/swappiness

echo "vm.swappiness = 0" >> /etc/sysctl.conf

# K8s-Pakete installieren

curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/k8s.list

apt-get update
apt-get install -y kubelet kubectl kubeadm
