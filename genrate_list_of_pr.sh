#!/usr/local/bin/bash
PATH_REPO="/Users/ppatel/Documents/aunsight-docker-dev/repos"
cd $PATH_REPO
for i in $(ls); do 
    i=${i%/};

    # echo -n "${i},";
    PRs=$(curl -sX  GET \
  'https://bitbucket.org/api/2.0/repositories/au-developers/'${i}'/pullrequests?pagelen=50&page=1&q=updated_on%20%3E%20%222019-01-30%22%20%20and%20destination.branch.name%20%3D%20%22develop%22%20%20and%20state%20!%3D%20%22DECLINED%22' \
  -H 'Authorization: Basic cGFyaW5nOnBnRXFReDN3QjhwTTVrMk5HSkpG' )
 
    total=$(echo $PRs | jq .size)
    if [[ ${total} -gt 50 ]] 
    then
        echo "${i} has more than 50 PRs FIX THEM"
        echo "Total size : "${total}
        # echo $(echo $PRs | jq '.values[]| "\(.title) ,\(.description) , \(.author.display_name)" ')
        exit 1 
    fi

    echo "$PRs" | jq -r '.values[]| "\(.source.repository.name),\"\(.title)\",\(.author.display_name),\(.links.html.href)"'


done