#!/bin/bash

VERSION=$1
#echo $VERSION

cd /usr/local/bin/
curl https://artifacts.aunalytics.com/toolbelt/Toolbelt-latest/version.txt
sudo rm /usr/local/bin/aunsight-toolbelt2-macos


if [ -n "$VERSION" ]; then
  sudo wget https://artifacts.aunalytics.com/toolbelt/Toolbelt-V$VERSION/aunsight-toolbelt2-macos
else
  sudo wget https://artifacts.aunalytics.com/toolbelt/Toolbelt-latest/aunsight-toolbelt2-macos
fi

sudo chmod +x aunsight-toolbelt2-macos
