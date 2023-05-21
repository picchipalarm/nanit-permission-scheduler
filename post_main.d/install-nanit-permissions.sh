#!/bin/bash
#set -e

NANIT_PERMISSION_FOLDER="/home/pi/run/nanit-permissions"
FIREWALLA_CRON_FILE="/home/pi/.firewalla/config/user_crontab"
FIREWALLA_LOG_FILE="/home/pi/logs/nanit_permissions.log"
#NANIT_PERMISSION_FOLDER="/Users/dev/repos_ghorg/github/nanit-permission-scheduler/out/gitclone"
#FIREWALLA_CRON_FILE="/Users/dev/repos_ghorg/github/nanit-permission-scheduler/out/cron_file"
#FIREWALLA_LOG_FILE="/Users/dev/repos_ghorg/github/nanit-permission-scheduler/out/logs.log"

logd() {
  echo "$(date +%FT%X)" "$1"  >> $FIREWALLA_LOG_FILE
}

logd "Starting install-nanit-permissions"

if [ -d "$NANIT_PERMISSION_FOLDER" ]
then
  logd "Directory $NANIT_PERMISSION_FOLDER exists, pulling latest."
  git -C $NANIT_PERMISSION_FOLDER pull
else
  logd "Directory $NANIT_PERMISSION_FOLDER does not exists, cloning."
  mkdir -p $NANIT_PERMISSION_FOLDER
  git clone https://github.com/picchipalarm/nanit-permission-scheduler.git $NANIT_PERMISSION_FOLDER
fi

logd "Installing new crontab"
touch $FIREWALLA_CRON_FILE
cp $NANIT_PERMISSION_FOLDER/config/user_crontab $FIREWALLA_CRON_FILE

logd "Finished install-nanit-permissions"
