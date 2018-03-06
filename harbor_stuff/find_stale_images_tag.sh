#!/bin/bash
count=30
final_repos=""
while [[ $count -eq 30 ]]; do
  url="https://registry.aunalytics.com:5000/v2/_catalog?n=${count}&last=${last_repo}"
  response=$(curl -s --request GET --url $url)
  repos=$(echo $response | jq -r '.repositories[]' )

  count=$(echo $repos|wc -w|tr -d " ")
  final_repos="${final_repos} ${repos}"
  # for repo in $repos; do
  #   tags=$(curl  -s --request GET --url "https://registry.aunalytics.com:5000/v2/$repo/tags/list" | jq -r '.tags[]'|wc -w | tr -d " " )
  #   sum=$(($sum+$count))
  #   echo $sum $repo $tags
  last_repo=$(echo $response | jq -r '.repositories[-1]' )
  # done
  # sum=$(($sum+$count))
 echo $last_repo
done
final_repos=$(cat temp_2)
for repo in $final_repos; do
  oldregtags=$(curl  -s --request GET --url "https://registry.aunalytics.com:5000/v2/$repo/tags/list" | jq -r '.tags[]'| sort -h)
  if [[ $repo = *"/"* ]]; then
    new_repo=$repo
  elif [[ $repo = "aunsight-"* ]]; then
    project="aunsight"
    new_repo="$project/$repo"
  elif [[ $repo = *"_webapp" ]]; then
    project="client_webapp"
    new_repo="$project/$repo"
  else
    echo "ignore repo"
    echo $repo
    continue
  fi
  newregtags=$(curl -s https://registrynew.aunalytics.com/api/repositories/$new_repo/tags/   --header 'Authorization: Basic YWRtaW46SGFyYm9yMTIzNDU=' | jq -r '.[].name' | sort -h)
  missing_tags=$(grep -Fxv -f <(echo "$newregtags") <(echo "$oldregtags"))
  comman_tags=$(grep -Fx -f <(echo "$newregtags") <(echo "$oldregtags"))
  echo $repo
  for comman_tag in $comman_tags; do
  new_sha=$(curl -X GET "https://registrynew.aunalytics.com/api/repositories/$new_repo/tags/$comman_tag" -s | jq -r ".created")
  old_sha1=$(curl -X GET "https://registry.aunalytics.com:5000/v2/$repo/manifests/$comman_tag" -s -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' | jq -r '.config.digest')
  old_sha=$(curl -sL --request GET --url https://registry.aunalytics.com:5000/v2/$repo/blobs/"$old_sha1"| jq -r '.created')
  if [[ $new_sha != "${old_sha}" ]]; then
     echo "images are different"
     #  echo "${repo} ${comman_tag}" "old_sha" ${old_sha} "new_sha"
     echo "${repo} ${comman_tag} old_sha ${old_sha} new_sha ${new_sha}"
     docker pull registry.aunalytics.com:5000/$repo:$comman_tag
     docker tag registry.aunalytics.com:5000/$repo:$comman_tag registrynew.aunalytics.com/$new_repo:$comman_tag
     docker push registrynew.aunalytics.com/$new_repo:$comman_tag
     docker rmi registry.aunalytics.com:5000/$repo:$comman_tag registrynew.aunalytics.com/$new_repo:$comman_tag
  fi
  done
  for missing_tag in $missing_tags;do
    echo "images are missing"
    echo $repo $missing_tag
     docker pull registry.aunalytics.com:5000/$repo:$missing_tag
     docker tag registry.aunalytics.com:5000/$repo:$missing_tag registrynew.aunalytics.com/$new_repo:$missing_tag
     docker push registrynew.aunalytics.com/$new_repo:$missing_tag
     docker rmi registry.aunalytics.com:5000/$repo:$missing_tag registrynew.aunalytics.com/$new_repo:$missing_tag
  done
done
