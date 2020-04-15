#!/bin/bash
#  By Parin Patel  April2020

# Test for OpenSSL - if not installed stop here.
if ! [[ -x $(which kubectl) ]]; then
  printf "\Kubectl not found or not executable.\nPlease install Kubectl before proceeding.\n\n"
  exit 1
fi

if ! [[ -x $(which yq) ]]; then
  printf "\yq not found or not executable.\nPlease install yq before proceeding.\n\n"
  exit 1
fi

if ! [[ -x $(which kubeval) ]]; then
  printf "\kubeval not found or not executable.\nPlease install kubeval before proceeding.\n\n"
  exit 1
fi
DRY_RUN=0
DEBUG=0
TTL_TO_CLEANUP=30
volumelist=./volume.csv
temp_kubectl="/tmp/kubectl_apply.yaml"
usage="
$(basename "$0") [-h] [-v] [-d] [-t ttlSecondsAfterFinished] [-s volumelist]

Retrieve the expiration date(s) on SSL certificate(s) using OpenSSL.

Usage:
    -h  Help

    -t  Amount of seconds to wait for ttlSecondsAfterFinished (default is 30 secs)
        Example: -t 3
    
    -v  Verbos
    
    -d  Dry Run

    -s  volumes from VOLUME_FILE
        Example:      -s ./websites.txt
        List format:  'sonardb-data,build_pipeline-sonardb_postgresql10_data' (one per line)

Example:
    $ $(basename "$0") -c -t 30 -s ./websites.txt
"

parse_path() {
    volume_name=""
    volume_path=""
    volume_name=$(echo $volume | awk '$1 ~ /^.*/' | cut -d',' -f1)
    volume_path=$(echo $volume | awk '$1 ~ /^.*/' | cut -d',' -f2)
}

wait_for_job_to_finish(){
  kubectl wait --for=condition=complete --labels "purpose=copy-data" --timeout 600
}

apply_kubectl(){
  cp creation.yml ${temp_kubectl}
  sed -i'' -e  's#OLD_NFS_PATH#'"${volume_path}"'#g' ${temp_kubectl}
  sed -i'' -e  's#VOL_NAME#'"${volume_name}"'#g' ${temp_kubectl}

  if [[ $DEBUG -eq 1 ]] 
  then
    cat ${temp_kubectl} | yq . -y  
    # exit 0
  fi
  if [[ $DRY_RUN -eq 1 ]]
  then
    kubectl apply -f ${temp_kubectl}  --dry-run=server
  else
    echo "going in non dry run"
    kubectl apply -f ${temp_kubectl} 
    wait_for_job_to_finish
    sleep ${TTL_TO_CLEANUP}
  fi
  if [[ ${DRY_RUN} -eq 1 ]]
  then
    echo "do Nothing"
  else
    kubectl delete PersistentVolume/nfs-data-old-data PersistentVolumeClaim/pvc-old  --dry-run=server
  fi
}


output_volume(){
  parse_path
  apply_kubectl
}


list_lookup() {
    file_contents=$(<$volumelist)
    while IFS= read -r volume; do
      if ! [[ -z $volume ]]; then
        output_volume
      fi
    done <<<"$file_contents"
    echo
}

while getopts ':hvds:t:' option; do
  case "$option" in
    h) printf "$usage"
       exit 0
       ;;
    v) DEBUG=1
       ;;
    d) DRY_RUN=1
       ;;
    s) volumelist=$OPTARG
       [[ -r $volumelist ]] && list_lookup || printf "\nFile not found/not readable. Permissions?\n\n"; exit 1;
       exit 0
       ;;
    t) timeout=$OPTARG
      TTL_TO_CLEANUP=${timeout}
       ;;
    :) printf "\nYou specified a flag that needs an argument.\n$usage" 1>&2
       exit 1
       ;;
    *) printf "\nI do not understand '"$1" "$2"'.\n$usage" 1>&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))


