#!/bin/bash
declare -A sites
sites=( ["graphite"]=443 ["jenkins"]=443 ["graphite"]=443 ["sonar"]=443 ["alerts"]=443 ["webprod"]=443 ["artifacts"]=443 ["apiprod"]="7900/token-public-key" ["registry"]=5000 )
for i in  "${!sites[@]}" ; do
  if [ $(curl -s -o /dev/null -w "%{http_code}" "https://$i.aunalytics.com:${sites[$i]}" ) -eq 200 ]; then
    echo "sites.${i}_${sites[$i]}.uptime 1 $(date +%s)" ;
    echo "sites.${i}_${sites[$i]}.repsonsetime $(curl -s -o /dev/null -w "%{time_total}" "https://$i.aunalytics.com:${sites[$i]}")  $(date +%s)" ;
  else
    echo "sites.${i}_${sites[$i]}.uptime 0 $(date +%s)";
  fi
done

exit 0
