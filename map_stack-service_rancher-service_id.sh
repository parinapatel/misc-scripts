#!/usr/bin/env bash
a=$(./rancher --env 1a862 inspect aunsight2 | jq .serviceIds[] )
for i in  $a ; do i=${i%\"};
i=${i#\"};
temp=$(./rancher --env 1a862 inspect ${i} | jq .name);
echo "RACHER_SERVICE_${temp#\"aunsight-}_ID=$i";
done
