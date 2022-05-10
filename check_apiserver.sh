#!/bin/sh
 
if netstat -nltp | grep -q 6443; then
    echo OK 
    return 0
else
    echo "Error HaProxy down"
    return 1
fi
