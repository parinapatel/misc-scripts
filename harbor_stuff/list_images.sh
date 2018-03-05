#!/bin/bash
count=300
sum=0
while [[ $count -eq 300 ]]; do
  url="https://registry.aunalytics.com:5000/v2/_catalog?n=${count}&last=${last_repo}"
  repos=$(curl -s --request GET --url $url |jq -r '.repositories[]' )
  count=$(echo $repos|wc -w|tr -d " ")
  for repo in $repos; do
    tags=$(curl  -s --request GET --url "https://registry.aunalytics.com:5000/v2/$repo/tags/list" | jq -r '.tags[]'|wc -w | tr -d " " )
    sum=$(($sum+$count))
    echo $sum $repo $tags
    last_repo=$repo
  done
  sum=$(($sum+$count))
  echo $sum
done
