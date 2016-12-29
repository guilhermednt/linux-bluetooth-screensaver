#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCAL_DEVICE=DC:53:60:11:50:66
LOCK_DEVICE=70:14:A6:0B:B1:2B
DEV_NAME="null"
INTERVAL=5 # in seconds
FAIL_LIMIT=3

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
FAILS=0
while [ 1 ]; do
	checkDevice
	if [ "$checkResult" = "0" ]; then
		FAILS=$(expr $FAILS + 1)
		echo "Failed Checks: $FAILS"
		if [ "$FAILS" -ge "$FAIL_LIMIT" ]; then
			echo "Locking!";
			FAILS=0
			$DIR/lock
		else
			sleep 1
		fi
	else
		if [ "$FAILS" -gt 0 ]; then
			echo "Recovered"
		fi
		FAILS=0
	fi
	sleep $INTERVAL
done
