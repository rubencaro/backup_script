#!/bin/bash

# this can nicely be run by a simple script inside /etc/cron.daily like this:
#       su - user -c /path/to/backup.sh
#

remote_user='miriam'
remote_host='192.168.1.3'
dest_path="/dest/path/on/remote"
remote_run="ssh $remote_user@$remote_host"

sources="$HOME/Documentos"
excludes="--exclude=*~ --exclude=.*~ --exclude=.cache --exclude=Trash --exclude=Ubuntu*One --exclude=.mozilla/firefox"
max_snaps=7

mkdir -p $HOME/.backup
log="$HOME/.backup/rotated_backup.log"

# check if rotation is needed
$remote_run "ls $dest_path/snap.0/*" # if snap.0 is empty then it's not needed
if [ '0' = "$?" ]; then
  echo "Rotating $max_snaps snaps... most recent snap will be saved on snap.0."

  # avoid file not existing errors in the first $max_snaps runs
  $remote_run "/bin/mkdir -p $dest_path/snap.{0..$max_snaps}" &>> $log

  # rotation freeing snap 0, deleting last snap
  $remote_run "/bin/rm -rf $dest_path/snap.$max_snaps"
  for i in $(seq $max_snaps -1 1)
  do
    $remote_run "/bin/mv $dest_path/snap.$[${i}-1] $dest_path/snap.${i}" &>> $log
  done
fi

# avoid file not existing errors in the first run
$remote_run "/bin/mkdir -p $dest_path/snap.{0..1}" &>> $log

# transfer files hard-linking snap 0 to snap 1
/usr/bin/rsync -avxhiz --numeric-ids --delete --delete-excluded --log-file=$log --link-dest=$dest_path/snap.1 $excludes $sources $remote_user@$remote_host:$dest_path/snap.0/
