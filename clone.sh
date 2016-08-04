#!/usr/bin/bash

#cloneSource='centos-mininst'
vmImagePath='/vm-images'
channelPath='/var/lib/libvirt/qemu/channel/target'

usage() {
    echo "Usage $0: guest [-d|--delete -s|--start]"
}

cloneSys() {
    local guest="$1"
    local cloneSource="$2"
    echo "Clone $guest from $cloneSource"
    virt-clone  --connect qemu:///system \
                --original $cloneSource \
                --name $guest \
                --file $vmImagePath/$guest.img
}

editChan() {
    local guest="$1"
    echo "Edit $guest channel path.."
    virt-xml $guest --edit --channel \
        path="$channelPath/domain-$guest/org.qemu.guest_agent.0"
}

startGuest() {
    local guest="$1"
    echo "Starting $guest"
    virsh start $guest
}

killGuest() {
    local guest="$1"
    echo "Annihilating $guest"
    virsh destroy $guest
    virsh undefine $guest
    rm -f $vmImagePath/$guest.img
}

# handle options
if [ $# -eq 2 ]
then
    # annihilate guest
    if [ $2 == "-d" -o $2 == "--delete" ]
        then
        killGuest $1
    # start guest
    elif [ $2 == "-s" -o $2 == "--start" ]
        then
        startGuest $1
    else
        # clone system
        cloneSys $1 $2
        editChan $1
    fi

# catch-all
else
    usage
    exit 1
fi
