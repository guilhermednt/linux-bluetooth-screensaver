#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f /usr/bin/solo ]; then
    sudo ln -s $DIR/solo/solo /usr/bin/solo
fi

