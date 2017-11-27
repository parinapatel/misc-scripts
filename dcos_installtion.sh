#!/bin/bash
sudo yum install -y tar wget git
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y epel-release
sudo bash -c 'cat > /etc/yum.repos.d/wandisco-svn.repo <<EOF
[WANdiscoSVN]
name=WANdisco SVN Repo 1.9
enabled=1
baseurl=http://opensource.wandisco.com/centos/7/svn-1.9/RPMS/\$basearch/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF'
sudo yum update systemd
sudo yum groupinstall -y "Development Tools"
sudo yum install -y apache-maven python-devel python-six python-virtualenv java-1.8.0-openjdk-devel zlib-devel libcurl-devel openssl-devel cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel apr-util-devel
wget http://www.apache.org/dist/mesos/1.4.0/mesos-1.4.0.tar.gz
tar -zxf mesos-1.4.0.tar.gz
