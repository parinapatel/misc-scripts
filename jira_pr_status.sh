#!/usr/local/bin/bash
JIRA_URL="$1"
TOKEN="$2"
SWIM_LANE="$3"
# ./jira_pr_status.sh aunalytics.atlassian.net  cGFyaW4ucGF0ZWxAYXVuYWx5dGljcy5jb206dlpRUm9SUm9PcjZkYmJJOTVKNmpCMDk1  'Quality Assurance'
if [[ $# -ne 3 ]]
then
  echo "usage ./jira_pr_status.sh JIRA_URL authToken Swimlane(Quality Assurance or Production Ready)"
fi

if [[ "$SWIM_LANE"  == "Quality Assurance" ]]
then
echo "$SWIM_LANE"
JIRA_TICKET_ID=$(curl -s --location --request POST "https://${JIRA_URL}/rest/api/2/search" \
--header 'Content-Type: application/json' \
--header "Authorization: Basic ${TOKEN}"  \
--data-raw '{
	"jql" : "project = AUN AND status = \"Quality Assurance\"",
	"fields": ["id"]
}' | jq '.issues[].id' | jq --slurp ' . | @tsv' -r)
echo ${JIRA_TICKET_ID}

elif [[ "$SWIM_LANE"  == "Production Ready" ]]
then
    JIRA_TICKET_ID=$(curl --location -Ls --request POST "https://${JIRA_URL}/rest/api/2/search" \
--header 'Content-Type: application/json' \
--header "Authorization: Basic ${TOKEN}"  \
--data-raw '{
	"jql" : "project = AUN AND status = \"Production Ready\"",
	"fields": ["id"]
}' | jq '.issues[].id' | jq --slurp ' . | @tsv' -r)

fi


for id in ${JIRA_TICKET_ID}
do
jira_id=$(curl --location -Ls --request GET "https://${JIRA_URL}/rest/api/2/issue/${id}?fields=summary" \
--header 'Content-Type: application/json' \
--header "Authorization: Basic ${TOKEN}" | jq '.| "\(.key) | \(.fields["summary"])"' -r  )

temp=$(curl --location -s --request POST "https://${JIRA_URL}/jsw/graphql?operation=DevDetailsDialog" \
--header 'content-type: application/json' \
--header "Authorization: Basic ${TOKEN}" \
--data-raw '{"query":"query DevDetailsDialog ($issueId: ID! ) {developmentInformation(issueId: $issueId){details { instanceTypes{repository{name url pullRequests { url name status } }  danglingPullRequests { url name status } } } } }","variables":{"issueId":"'"${id}"'"}}')
# echo $temp |  jq '.data.developmentInformation.details.instanceTypes[].repository[] ' -j 
echo $temp |  jq '.data.developmentInformation.details.instanceTypes[].repository[] | .name as $repo | .pullRequests[]? | "'"${jira_id}"' | \($repo) | \(.name) |\(.status) | \(.url)"'
echo $temp |  jq '.data.developmentInformation.details.instanceTypes[] | .danglingPullRequests[]? | " '"${jira_id}"' |None | \(.name) |\(.status) | \(.url)"'
done
