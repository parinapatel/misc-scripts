#!/bin/bash
RANCHER_METADATA_PATH="/home/ec2-user/graphite_data/whisper/rancher_metadata"
MODIFY_TIME_MIN=1440 # 24 h * 60 min
if [[ $(find $RANCHER_METADATA_PATH -name '*.wsp' -mmin +$MODIFY_TIME_MIN -print) != ""  ]]; then
  find $RANCHER_METADATA_PATH -name '*.wsp' -mmin +$MODIFY_TIME_MIN -print
  find $RANCHER_METADATA_PATH -name '*.wsp' -mmin +$MODIFY_TIME_MIN -print  | xargs sudo rm
fi
EMPTY_DIR_LIST=$(find $RANCHER_METADATA_PATH -type d -empty)

while [[ $EMPTY_DIR_LIST != "" ]]; do
 echo $EMPTY_DIR_LIST
 find $RANCHER_METADATA_PATH -type d -empty | xargs sudo rm  -r
 EMPTY_DIR_LIST=$(find $RANCHER_METADATA_PATH -type d -empty)
done
