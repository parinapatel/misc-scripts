#!/bin/bash
lines=$(docker -H 0.0.0.0:2375 ps -a | grep "bin/exec-graph" | awk '/ / { print $1 }'| wc -l )
echo $lines
output=$(docker -H 0.0.0.0:2375 inspect $(docker -H 0.0.0.0:2375 ps -a | grep "bin/exec-graph" | awk '/ / { print $1 }'))
for (( i=0; i < ${lines} ; i++ ))
do
echo -n "Name : "
echo $output | jq .[$i].Name | tr -d '\n'

# echo -n "  Created : "
# echo $output | jq .[$i].Created | tr -d '\n'
echo -n "ORG : "
echo $output | jq .[$i].Config.Cmd[9] | tr -d '\n'

echo -n "  Job Id : "
echo $output | jq .[$i].Config.Cmd[5]

done
