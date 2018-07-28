#!/bin/sh

# This script will iterate over ip addresses to update the arp cache. 
# Then it will print out the results of the arp -a command, 
# which will list the devices that responded to ping.

# For this to work, you may need to configure your firewall.

if [$1 == ""] 
then
	echo "You must give a base IP address without the host. \nFor example, if you have an IP Address of 198.162.1.0, you would pass 198.162.1 as the first argument.";
	set -e;
	exit 1;
fi

echo "Starting IP scan...";

IP_BASE="$1"

TIMESTAMP="$(date '+%Y%m%d%ss')";
FILE_NAME="ping-results-$TIMESTAMP.txt";

for i in `seq 1 254`; 
do
	ping -c 1 -q $IP_BASE.$i >> $FILE_NAME & 
done 

echo "Completed IP scan."
echo "Loading data on devices that responded to ping...\n";

echo "$(arp -a | grep -v '(incomplete)' --count)" devices found;

# Print full list of devices
echo "$(arp -a | grep -v '(incomplete)')";

echo "\n\n";
echo "Full ping command results were logged to $FILE_NAME";
