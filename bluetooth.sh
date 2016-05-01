#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEVICE=70:14:A6:0B:B1:2B
DEV_NAME="null"
INTERVAL=5 # in seconds

# Assumes you've already paired and trusted the device
while [ 1 ]; do
	opt=`hcitool name $DEVICE`
	if [ "$opt" = "$DEV_NAME" ]; then
		echo "Device '$opt' found"
	else
		echo "Can't find device $DEVICE ($DEV_NAME); locking!"
		$DIR/lock
	fi
	sleep $INTERVAL
done
