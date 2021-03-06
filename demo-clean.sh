#!/usr/bin/bash

prefix="$1"

if [ $# -gt 0 ]
then
    suffix=$1
    guestName="demo${suffix}"
    for i in {1..4}
    do
        ./clone.sh ${guestName}${i} -d
    done
else
    guestName="demo"
    for i in {1..4}
    do
        ./clone.sh ${guestName}${i} -d
    done
fi

ovsNetwork="ovs-br3"

virsh net-destroy $ovsNetwork
virsh net-undefine $ovsNetwork
