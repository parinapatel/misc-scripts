#!/bin/bash
if ! $(command -v rancher) ; then
echo "not avaible"
wget https://github.com/rancher/cli/releases/download/v0.6.5/rancher-linux-amd64-v0.6.5.tar.gz && tar xvf rancher-linux-amd64-v0.6.5.tar.gz && cd rancher-v0.6.5 && cp rancher /usr/bin/
rancher --version
fi

mkdir -p  /tmp/rancher_backup && cd /tmp/rancher_backup || exit 1
git clone git@bitbucket.org:au-developers/aunsight-rancher-backups.git
cd aunsight-rancher-backups || exit 1
bash backup_rancher.sh
git add .
git commit -m "backup $(date)"
git push
cd ..
rm -rf aunsight-rancher-backups
