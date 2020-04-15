DATA=$( curl -Ls http://auhdh.aunalytics.com:50070/webhdfs/v1/user/aunsight2/deployments/prod/organization/6efba1cc-94d0-4965-ae10-063868002181/models?op=LISTSTATUS | jq '.FileStatuses.FileStatus[].pathSuffix' -r )

for i in ${DATA}
do 
FILE_DATA=$(curl -Ls http://auhdh.aunalytics.com:50070/webhdfs/v1/user/aunsight2/deployments/prod/organization/6efba1cc-94d0-4965-ae10-063868002181/models/${i}?op=LISTSTATUS | jq '.FileStatuses.FileStatus[].pathSuffix' -r )
curl -Ls http://walleyehdh.walleye.aunalytics.com:50070/webhdfs/v1/user/aunsight2/deployments/prod/organization/6efba1cc-94d0-4965-ae10-063868002181/models/${i}?op=LISTSTATUS
# for j in ${FILE_DATA}
# do

# DATA_DATA=$(curl -Ls http://auhdh.aunalytics.com:50070/webhdfs/v1/user/aunsight2/deployments/prod/organization/6efba1cc-94d0-4965-ae10-063868002181/models/${i}/${j}?op=OPEN)
# done
done