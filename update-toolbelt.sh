#!/bin/bash

VERSION=$1
#echo $VERSION

mkdir -p ~/toolbelt
cd ~/toolbelt
curl https://artifacts.aunalytics.com/toolbelt/Toolbelt-latest/version.txt

if [ -n "$VERSION" ]; then
  curl https://artifacts.aunalytics.com/toolbelt/Toolbelt-V$VERSION/aunsight-toolbelt2-macos -o "toolbelt_new"
else
  curl https://artifacts.aunalytics.com/toolbelt/Toolbelt-latest/aunsight-toolbelt2-macos -o "toolbelt_new"
fi

mv aunsight-toolbelt2-macos aunsight-toolbelt2-macos_old
mv toolbelt_new aunsight-toolbelt2-macos
chmod +x ./aunsight-toolbelt2-macos
