#!bin/bash
python /root/script.py $GRAPHITE_HOST
EXIT_CODE=$?
echo $EXIT_CODE
if [[ $EXIT_CODE != 0 ]]; then
  echo "FAILURE"
  exit 1
else
  echo "SUCCEEDED"
  exit 0
fi
