#!/bin/bash
# from cron every hour

remote_user='miriam'
remote_host='192.168.1.3'
dest_path="/media/miriam/backup/bigtime/"
home="/home/ruben"
sources="$home /etc"
excludes="--exclude=*~ --exclude=.*~ --exclude=.cache --exclude=Trash --exclude=Ubuntu*One --exclude=.mozilla/firefox"

mkdir -p $home/.backup
log="$home/.backup/backup.log"
last="$home/.backup/last_backup"
lock="/tmp/backup.lock"

# check last backup's ts
if [ -f $last ]; then
  secs_since_last=$[$(date +%s) - $(date -r $last +%s)]
  if [[ $[$(date +%s) - $secs_since_last] -lt 43200 ]]; then
    exit 0
  fi
fi

# try to create dest path
ssh $remote_user@$remote_host "/bin/mkdir -p $dest_path" &>> $log
# exit if no ssh connection
[ $? -ne 0 ] && exit 0

# exit if already running
[ -f $lock ] && exit 0
touch $lock

# transfer files
/usr/bin/rsync -avxhizu --numeric-ids --delete --delete-excluded --log-file=$log $excludes $sources $remote_user@$remote_host:$dest_path

# all done, mark the ts, release the lock
touch $last
rm $lock
