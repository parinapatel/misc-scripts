#!/bin/bash
#  By Parin Patel  April2020


# Test for OpenSSL - if not installed stop here.
if ! [[ -x $(which kubectl) ]]; then
  printf "\Kubectl not found or not executable.\nPlease install Kubectl before proceeding.\n\n"
  exit 1
fi


# 30 days is default on warnings - overidden on command line with '-d':
ttl_to_cleanup=30
# default name for file lists
mountlist=./websites.txt

### Clear/list/set defaults for variables ###
epoch_second=1
epoch_warning=$((ttl_to_cleanup*epoch_second))
regex_numbers='^[0-9]+$'
expire="0"
website=""
port=""
tls="0"
sTLS=""
show_tls=""
certfilename=""
location=""
filename=""
displaysite=""
#COLORS
color="0"
RED=$(tput setaf 1)    #expired!!
GREEN=$(tput setaf 2)  #within bounds
YELLOW=$(tput setaf 3) #warning/date close!
NC=$(tput sgr0)        #reset to normal
#
usage="
$(basename "$0") [-h] [-c] [-d DAYS] [-t TIMEOUT] [-f FILENAME] | [-w WEBSITE] | [-s SITELIST]

Retrieve the expiration date(s) on SSL certificate(s) using OpenSSL.

Usage:
    -h  Help

    -c  Color output

    -t  Amount of seconds to wait for ttlSecondsAfterFinished (default is 30 secs)
        Example: -t 3


    -w  Entry with 'volume_name,volume_path' FYI No '_' in name
        Example: -w 'sonardb-data,build_pipeline-sonardb_postgresql10_data'

    -s  volumes from VOLUME_FILE
        Example:      -s ./websites.txt
        List format:  'sonardb-data,build_pipeline-sonardb_postgresql10_data' (one per line)

Example:
    $ $(basename "$0") -c -t 30 -s ./websites.txt
"

#FUNCTIONS

is_integer() {
    if ! [[ "$1" =~ $regex_numbers ]]; then
      printf "\nError.\nNot a number. You used a parameter that requires a whole number.\n$usage"
      exit 1
    fi
}
menu_input() {
  echo
  echo "1: Enter file location of volumelist "
  echo "2: Enter an input in form of 'volume_name,volume_path' "
  echo
  read -p "Enter 1 or 2 (anything else quits): " -n 1 -r
  echo
}
get_lookup_input() {
    location=""
    echo
    read -p "Please enter the $lookuptype location: " location
}
set_format() {
    set_formatting="%-40s%-25s\n"
    set_formatting_green=$set_formatting
    set_formatting_yellow=$set_formatting
    set_formatting_red=$set_formatting
    printf "\nWarning is $ttl_to_cleanup seconds.\n"
    printf "Color is "
    if [[ $color == "1" ]]; then
      set_formatting_green="$GREEN%-40s$NC%-25s\n"
      set_formatting_yellow="$YELLOW%-40s$NC%-25s\n"
      set_formatting_red="$RED%-40s$NC%-25s\n"
      printf "enabled.\n\n"
    else
      printf "disabled.\n\n"
    fi
    printf "$set_formatting" "VOLUME_NAME" "VOLUME_PATH" "PVC_NAME"
    printf "$set_formatting" "--------" "---------------" "-------"
}

parse_path() {
    volume_name=""
    volume_path=""
    volume_name=$(echo $volume | awk '$1 ~ /^.*/' | cut -d',' -f1)
    volume_path=$(echo $volume | awk '$1 ~ /^.*/' | cut -d',' -f2)
}

check_expiry() {
    expire="0"

    if [ "$lookuptype" == "FILENAME" ]; then

      expire_date=$($openssl_timeout openssl x509 -in $certfilename$sTLS -noout -dates 2>/dev/null | \
                  awk -F= '/^notAfter/ { print $2; exit }')
    else
      expire_date=$($openssl_timeout openssl s_client -servername $website -connect $website:$port$sTLS </dev/null 2>/dev/null | \
                  openssl x509 -noout -dates 2>/dev/null | \
                  awk -F= '/^notAfter/ { print $2; exit }')
      # echo "Echo : $($openssl_timeout openssl s_client -servername $website -connect $website:$port$sTLS )";
    fi
}

output_site() {
    parse_path
    check_expiry
    if [ "$lookuptype" != "FILENAME" ]; then
      display_site="$website:$port$show_tls"
    else
      display_site="$filename"
    fi
    if   [[ $expire == "1" ]]; then
      printf "$set_formatting_yellow"  "$display_site" "$expire_date !"  # YELLOW OUTPUT - warning
    elif [[ $expire == "2" ]]; then
      printf "$set_formatting_red"     "$display_site" "$expire_date !!" # RED OUTPUT - expired
    elif [[ $expire == "3" ]]; then
      printf "$set_formatting"         "$display_site" "$expire_date !!!" # NO COLOR - NOT FOUND
    else
      printf "$set_formatting_green"   "$display_site" "$expire_date"    # GREEN OUTPUT
    fi
}

#

client_lookup() {
    lookuptype="WEBSITE"
    if [[ -z $website ]]; then #loop lookup - ask for input
      get_lookup_input
      website=$location
    fi
    set_format
    output_site
    lookuptype=""
    website=""
    echo
}

file_lookup() {
    lookuptype="FILENAME"
    if [[ -z $certfilename ]]; then #loop lookup - ask for input
      get_lookup_input
      certfilename=$location
    fi
    filename=$(basename -- "$certfilename")
    set_format
    output_site
    lookuptype=""
    filename=""
    echo
}
list_lookup() {
    lookuptype="FILELIST"
    file_contents=$(<$sitelist)
    set_format
    while IFS= read -r website; do
      if ! [[ -z $website ]]; then
        output_site
      fi
    done <<<"$file_contents"
    lookuptype=""
    echo
}

#HANDLE ARGUMENTS

while getopts ':hcd:f:s:w:t:' option; do
  case "$option" in
    h) printf "$usage"
       exit 0
       ;;
    c) color="1"
       ;;
    d) is_integer "$OPTARG"
       if [ "$OPTARG" -ge 1 -a "$OPTARG" -le 365 ]; then
         days_to_warn="$OPTARG"
         epoch_warning=$((days_to_warn*epoch_day))
       else
         printf "\nDays must be between 1 and 365\n$usage"
         exit 1
       fi
       ;;
    f) certfilename=$OPTARG
       [[ -r $certfilename ]] && file_lookup || printf "\nFile not found/not readable. Permissions?\n\n"; exit 1;
       exit 0
       ;;
    s) sitelist=$OPTARG
       [[ -r $sitelist ]] && list_lookup || printf "\nFile not found/not readable. Permissions?\n\n"; exit 1;
       exit 0
       ;;
    w) website=$OPTARG
       client_lookup
       exit 0
       ;;
    t) timeout=$OPTARG
       if [[ $(uname) == "Darwin" ]] ;
       then 
        openssl_timeout="gtimeout ${timeout}"
       else
        openssl_timeout="timeout ${timeout}";
       fi
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

#LOOP RUN (default if no flags)

if [ $# -eq 0 ]; then # no command line arguments/flags found
printf "\nNo flags used or available. Interactive mode.\n"
  while :
  do
    menu_input
    if [[ $REPLY == "1" ]]
    then
      file_lookup
    elif [[ $REPLY == "2" ]]
    then
      client_lookup
    else # exit
      [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi
  echo
  done
fi