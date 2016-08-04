#!/usr/bin/bash

if [ $# -gt 0 ]
then
    suffix=$1
    guestName="demo${suffix}"
    for i in {1..4}
    do
        ./clone.sh ${guestName}${i} -s
    done
else
    guestName="demo"
    for i in {1..4}
    do
        ./clone.sh ${guestName}${i} -s
    done
fi
