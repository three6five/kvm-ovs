#!/usr/bin/bash

cloneSys() {
    echo "Clone $guest from $cloneSource"
    virt-clone  --connect qemu:///system \
                --original centos-mininst \
                --name $guest
                --file $vmImagePath/$guest.img
}

editChan() {
    echo "Edit $guest channel path.."
    virt-xml $guest --edit --channel \
        path="$channelPath/domain-$guest/org.qemu.guest_agent.0"
}

