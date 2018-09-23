#!/bin/bash

echo "Preparing for launch... 👨‍🚀"

# Check if we have the proper configuration via a .env
if [ ! -f .env ]; then
    echo "❌ Could not find the .env file. Launch aborted."
    exit 1
fi

# Make configuration available via .env file
source .env

# Store the current time
NOW=$(date +'%m-%d-%Y-%H-%M')

# Create a timestamped file name for this launch
DEPLOYMENT_LOG_FILE=$DEPLOYMENT_LOG_DIRECTORY"/"$NOW-deployment-log.txt

# Pre-deployment hook
if [ -n $PRE_DEPLOYMENT_SCRIPT ]; then 
  source $PRE_DEPLOYMENT_SCRIPT >> $DEPLOYMENT_LOG_FILE
fi

# Check if we have the deployment log directory
if [ ! -d "$DEPLOYMENT_LOG_DIRECTORY" ]; then
  mkdir -p $1 $DEPLOYMENT_LOG_DIRECTORY
fi

# Rsync new files and delete removed files
rsync -e "/usr/bin/ssh" -v -rz --checksum --delete $LOCAL_PUBLIC_DIRECTORY $SSH_USER@$REMOTE_HOST:$REMOTE_PUBLIC_DIRECTORY >> $DEPLOYMENT_LOG_FILE

# Check if the deployed site is returning an OK response
# https://superuser.com/questions/272265/getting-curl-to-output-http-status-code#442395
HTTP_OK_RESPONSE="200"
HTTP_RESPONSE=$(curl -s -o /dev/null -I -w "%{http_code}" $WEB_URL)

if [[ $HTTP_RESPONSE == $HTTP_OK_RESPONSE ]]; then
  echo "Launched! 🚀"
else
  echo "Welp, something went wrong. 💥"
  echo "HTTP $HTTP_RESPONSE response from $WEB_URL";
fi