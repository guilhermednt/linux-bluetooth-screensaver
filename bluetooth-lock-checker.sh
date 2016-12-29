#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# log all:
solo -port=3802 $DIR/lock-checker.sh &>>/$DIR/lock-checker.log

# silent:
#solo -port=3802 $DIR/bluetooth.sh &>/dev/null

