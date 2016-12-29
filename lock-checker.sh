#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCAL_DEVICE=DC:53:60:11:50:66
LOCK_DEVICE=70:14:A6:0B:B1:2B
USB_SERIAL=ecaa93f773c18e6e476a3c4ff721d2d87f051b3e
DEV_NAME="null"
INTERVAL=5 # in seconds
FAIL_LIMIT=3

function checkBluetooth {
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
}

function checkUSB {
	RESULT=`usb-devices | grep $USB_SERIAL`
	if [ "$?" -ne 0 ]; then
		# USB device not found
		checkResult="0"
		return
	else
		# USB device found
		checkResult="1"
		return
	fi
}

function checkDevice {
	btEnabled=`hcitool dev | grep $LOCAL_DEVICE | wc -l`
	if [ -f ~/.disable-bt-lock ]; then
		enabled="0"
	else
		enabled="1"
	fi

	if [ "$enabled" = "0" ]; then
		checkResult="1"
		return
	fi

	checkUSB

	if [ "$btEnabled" = "1" ]; then
		checkBluetooth

		if [ "$checkResult" = "0" ]; then
			checkUSB
		fi
	fi

	return
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
		echo "OK"
	fi
	sleep $INTERVAL
done
