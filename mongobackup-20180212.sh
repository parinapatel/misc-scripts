#!/bin/bash

TIME=`/bin/date +%Y-%m-%d-%T`;
#TMPDIR=/home/au-admin/tmpmongo;
#TMPDIR=/mnt/AUengineering/backups/au2_prod_mongo/tmpmongo/;
DEST=/mnt/AUengineering/backups/au2_prod_mongo;
#/bin/rm -rf $TMPDIR;
#/bin/mkdir -p $TMPDIR;
/bin/mkdir -p $DEST;
#docker run --rm -v $DEST:/backup -e TIME="$TIME" --name backup_mongo --link mongodb-20170212:mongodb-20170212 mongo:3.4 mongodump --gzip --host mongodb-20170212 --port 27017 -o /backup/backup$TIME.gz
mongodump --host localhost --port 27017 --gzip --archive $DEST/backup$TIME.archive
# /usr/bin/mongodump -o $TMPDIR;
#STATUS=$?
# /bin/tar cvzf $DEST/backup$TIME.tgz $TMPDIR
#if [ $STATUS -eq 0 ]
#then
  #exit 0
#else
  #exit 1
#fi
