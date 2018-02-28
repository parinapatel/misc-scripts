#!/bin/bash
last_repo=""
count=3
sum=0
while [[ $count -eq 3 ]]; do
  url="https://registry.aunalytics.com:5000/v2/_catalog?n=${count}&last=${last_repo}"
  repos=$(curl -s --request GET --url $url |jq -r '.repositories[]' )
  count=$(echo $repos|wc -w|tr -d " ")
  for repo in $repos; do
    echo $repo
    project=$(echo $repo|cut -d "/" -f 1)
    tags=$(curl  -s --request GET --url "https://registry.aunalytics.com:5000/v2/$repo/tags/list" | jq -r '.tags[]')

    if [[ $repo = *"/"* ]]; then
      :
    elif [[ $repo = "aunsight-"* ]]; then
      project="aunsight"
      repo="$project/$repo"
    elif [[ $repo = *"_webapp" ]]; then
      project="client_webapp"
      repo="$project/$repo"
    else
      echo "bad $repo"
      project=""
    fi
if [[ $project != "" ]]; then
  echo $project
  check_project=$(curl -I -s -o /dev/null -w "%{http_code}" "https://registrynew.aunalytics.com/api/projects?project_name=$project" )
  echo $check_project
  if [[ $check_project -eq 200 ]]; then
    echo "$project exist"
  else
    response=$(curl -X POST -s -o /dev/null -w "%{http_code}" -u admin:Harbor12345 --url "https://registrynew.aunalytics.com/api/projects"  -H 'Content-Type: application/json'  -d "{  \"project_name\": \"$project\",  \"public\": 1}")
    echo $response
    if [[ $response -eq 201 ]]; then
      echo "$project created"
    fi

  fi

  for tag in $tags; do
    docker pull registry.aunalytics.com:5000/$repo:$tag
    docker tag registry.aunalytics.com:5000/$repo:$tag registrynew.aunalytics.com/$repo:$tag
    docker push registrynew.aunalytics.com/$repo:$tag
    echo registry.aunalytics.com:5000/$repo:$tag
  done

  for tag in $tags; do
    docker rmi registrynew.aunalytics.com/$repo:$tag registry.aunalytics.com:5000/$repo:$tag
    echo registry.aunalytics.com:5000/$repo:$tag
  done

fi
last_repo=$repo

  done
  sum=$(($sum+$count))
  echo $sum
done
