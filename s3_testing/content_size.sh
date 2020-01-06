#!/usr/local/bin/bash
set -x
for((i=5;i<1024;i=i*2));
do
  echo $i
  curl -X PUT -f \
  https://apidev.aunalytics.com/resource/v2/resource/v2:d264cb5a-b46c-4685-92e5-11a7868bb65d/ \
  -H 'Content-Type: application/json' \
  -H 'authorization: Bearer 4eae8996-88f0-4319-9b5b-f20130efaa86' \
  -d '{
    "resource": {
      "id": "v2:d264cb5a-b46c-4685-92e5-11a7868bb65d",
        "s3": {
            "part_size": '${i}'
        }
    }
}' || exit 1
  echo "Uploading data"

 a=$({  time AU_CONFIG_FILE=~/.aunsight-toolbelt-dev-config.json /Users/ppatel/Downloads/aunsight-toolbelt2-macos d i --id c4552bdf-30c0-4573-9b11-7afd3c4aa341  -f /Users/ppatel/Downloads/parin-test.csv -O ; } 2>&1 | grep real )
echo "${i},${a}" >> analysis.csv
done
