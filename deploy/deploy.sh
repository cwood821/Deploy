#!/bin/bash

echo "Preparing for launch... 👨‍🚀"

# Set generic failure code
FAILURE_CODE=1

# Check if we have the proper configuration via a .env
if [ ! -f .env ]; then
    echo "❌ Could not find a .env file. Launch aborted."
    exit $FAILURE_CODE
fi

# Make configuration available via .env file
source .env

# Setup timestamp log file for this deployment
NOW=$(date +'%m-%d-%Y-%H-%M-%S')
DEPLOYMENT_LOG_FILE=$DEPLOYMENT_LOG_DIRECTORY"/"$NOW-deployment-log.txt

function run_deployment_hook_script() {
  STAGE=$1
  SCRIPT=$2
  # Script has value, exists, executable
  if [ ! -z $SCRIPT ] && [ -f $SCRIPT ] && [ -x $SCRIPT ]; then 
    ./$SCRIPT >> $DEPLOYMENT_LOG_FILE
    # Check that the hook script exited succesfully
    if [ "$?" -ne "0" ]; then
      echo "$STAGE script exited with a non-succesfull error code." >> $DEPLOYMENT_LOG_FILE
      exit $FAILURE_CODE
    fi
  else 
    echo "No $STAGE script found or it is not executable." >> $DEPLOYMENT_LOG_FILE
  fi

  return 0
}

run_deployment_hook_script "predeployment" $PRE_DEPLOYMENT_SCRIPT

# Check if we have the deployment log directory, and that it has a name given in the 
# the configuration
if [ ! -d "$DEPLOYMENT_LOG_DIRECTORY" ] && [ ! -z $DEPLOYMENT_LOG_DIRECTORY ]; then
  mkdir -pv $1 $DEPLOYMENT_LOG_DIRECTORY
elif [ -z $DEPLOYMENT_LOG_DIRECTORY ]; then
  echo "No name given for deployment log directory."
  exit $FAILURE_CODE
fi 

# Rsync new files and delete removed files
rsync -e "/usr/bin/ssh" -v -rz --checksum --delete $LOCAL_PUBLIC_DIRECTORY $SSH_USER@$REMOTE_HOST:$REMOTE_PUBLIC_DIRECTORY >> $DEPLOYMENT_LOG_FILE

# Check if rsync failed
if [ "$?" -ne "0" ]
then
  echo "Welp, something went wrong."
  exit $FAILURE_CODE
fi

# Check if the deployed site is returning an OK response
HTTP_OK_RESPONSE="200"
HTTP_RESPONSE=$(curl -s -o /dev/null -I -w "%{http_code}" $WEB_URL)

if [[ $HTTP_RESPONSE == $HTTP_OK_RESPONSE ]]; then
  echo "Launched! 🚀"
else
  echo "Houston, we have a problem."
  echo "HTTP $HTTP_RESPONSE response from $WEB_URL" | tee -a $DEPLOYMENT_LOG_FILE;
  exit $FAILURE_CODE
fi

run_deployment_hook_script "post-deployment" $POST_DEPLOYMENT_SCRIPT

# Complete succesfully
exit 0