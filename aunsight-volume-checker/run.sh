#!/bin/bash

/root/process.sh | au2 log write -i ${AU_LOGGER_STREAM} -s 
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]] 
then
  echo "FAILED"
  exit 1 
else
  echo "SUCCEEDED"
  exit 0
fi