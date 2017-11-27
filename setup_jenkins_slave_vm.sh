#!/bin/bash
vi /etc/sysconfig/network-scripts/ifcf0ens3



yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
echo '{"hosts": ["tcp://0.0.0.0:2375"," unix:///var/run/docker.sock"],  "storage-driver": "overlay2","storage-opts": ["overlay2.override_kernel_check=true"]}' > /etc/docker/daemon.json
systemctl restart docker && systemctl enable docker
iptables -F
yum install -y epel-release && yum groupinstall -y 'Development Tools'
yum install -y net-tools bridge-utils
pkill docker
iptables -t nat -F
ifconfig docker0 down
brctl delbr docker0
systemctl restart docker
iptables -F
