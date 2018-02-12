#!/bin/sh
TIME=`/bin/date +%Y-%m-%d-%T`;
#TMPDIR=/home/au-admin/tmpmongo;
TMPDIR=/mnt/AUengineering/backups/au2_prod_mongo/tmpmongo/;
DEST=/mnt/AUengineering/backups/au2_prod_mongo/;
/bin/rm -rf $TMPDIR;
/bin/mkdir -p $TMPDIR;
/bin/mkdir -p $DEST;
docker run --rm -d -v $TMPDIR:/backup -e TIME="$TIME" --hostname backup_mongo --link mongodb_20170212:mongodb mongo:3.4 mongorestore --gzip --host mongodb --port 27017 -o backup$TIME.gz
STATUS=docker inspect backup_mongo --format='{{.State.ExitCode}}'
# /usr/bin/mongodump -o $TMPDIR;
# STATUS=$?
# /bin/tar cvzf $DEST/backup$TIME.tgz $TMPDIR
if [ $STATUS -eq 0 ]
then
  exit 0
else
  exit 1
fi
