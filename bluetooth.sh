#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCAL_DEVICE=DC:53:60:11:50:66
LOCK_DEVICE=70:14:A6:0B:B1:2B
DEV_NAME="null"
INTERVAL=5 # in seconds

function checkDevice {
	enabled=`hcitool dev | grep $LOCAL_DEVICE | wc -l`
	if [ -f ~/.disable-bt-lock ]; then
		enabled="0"
	fi
	if [ "$enabled" = "1" ]; then
		opt=`hcitool name $LOCK_DEVICE`
		if [ "$opt" = "$DEV_NAME" ]; then
			#echo "Device '$opt' found"
			checkResult="1"
			return
		else
			#echo "Can't find device $LOCK_DEVICE ($DEV_NAME)"
			checkResult="0"
			return
		fi
	#else
		#echo "Bluetooth disabled"
	fi
	checkResult="1"
}

# Assumes you've already paired and trusted the device
while [ 1 ]; do
	 checkDevice
	 if [ "$checkResult" = "0" ]; then
	 	echo "Check 1 Failed"
	 	sleep 1
	 	checkDevice
	 	if [ "$checkResult" = "0" ]; then
	 		echo "Failed 2 tests! Locking!"
	 		$DIR/lock
	 	fi
	 #else
	 #	echo "OK"
	 fi
	sleep $INTERVAL
done
