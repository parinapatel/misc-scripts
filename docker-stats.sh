#!/bin/bash
HOST=$1
STACK_NAME=$2
LIST_OF_CONTAINERS=$(curl -s $HOST/containers/json | jq '.[].Names[]' | grep  $STACK_NAME|sed "s/\"\///"|sed "s/\"//")
for i in $LIST_OF_CONTAINERS ;
  do  metrics-docker-stats.rb -H $HOST  -c $i -p http -s $HOSTNAME -n -P |grep -E 'usage_percent|memory_stats.usage'|sed "s/\(.*\)\.r-aunsight2-prod-\([a-z\-]*\)-\([0-9]\)-.[0-9a-z]*\.\(.*\)/\1.\2-\3.\4/p";
done
