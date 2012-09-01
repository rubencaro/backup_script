#!/bin/bash

remote_user='miriam'
remote_host='192.168.1.3'
dest_path="/media/externo/.backup/viajero/"

sources='/home/ruben/Documentos'
excludes='--exclude=*~ --exclude=.*~'

mkdir -p $HOME/.backup
log="$HOME/.backup/backup.log"

ssh $remote_user@$remote_host "/bin/mkdir -p $dest_path" &>> $log

# transferir archivos
/usr/bin/rsync -avxhizu --numeric-ids --delete --delete-excluded --log-file=$log $excludes $sources $remote_user@$remote_host:$dest_path
