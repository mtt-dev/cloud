#!/bin/bash

kubeadm init --pod-network-cidr=192.168.0.0/16

curl -sS https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml \
   -o kube-flannel.yml

KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f kube-flannel.yml

kubeadm token create --print-join-command 1>join-command

cp /etc/kubernetes/admin.conf ./
