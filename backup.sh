#!/bin/bash

# this can nicely be run by a simple script inside /etc/cron.daily like this:
#       su - user -c /path/to/backup.sh
#

remote_user='miriam'
remote_host='192.168.1.3'
dest_path="/dest/path/on/remote/"

sources="$HOME/Documentos"
excludes="--exclude=*~ --exclude=.*~ --exclude=.cache --exclude=Trash --exclude=Ubuntu*One --exclude=.mozilla/firefox"

mkdir -p $HOME/.backup
log="$HOME/.backup/backup.log"

ssh $remote_user@$remote_host "/bin/mkdir -p $dest_path" &>> $log

# transferir archivos
/usr/bin/rsync -avxhizu --numeric-ids --delete --delete-excluded --log-file=$log $excludes $sources $remote_user@$remote_host:$dest_path
