#!/bin/bash

for((i=0;i<${LOOP_COUNT};i++));
do
  echo $i
  au2 d dl ${ATLAS_RECORD_ID} >> ${AU_SCRATCH_DIR}/data || exit 1
  ls -lah  ${AU_SCRATCH_DIR}
  df -h 
done
