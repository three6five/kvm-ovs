#!/usr/bin/bash

prefix="$1"

ovsNetwork="ovs-br3"

for i in {1..4}
do 
    ./clone.sh demo${prefix}${i} -d
done

virsh net-destroy $ovsNetwork
virsh net-undefine $ovsNetwork
