#!/usr/bin/bash

set -e

#guest='default'
#ovsNetwork='default'
#intfNum=2
#vlan='Vlan-1'

cloneSource='centos-mininst'
vmImagePath='vm-images'
channelPath='/var/lib/libvirt/qemu/channel/target'

usage() {
    echo "Usage: $0 guest [-a ovsNetwork vlan]"
    exit 1;
}

fullUsage() {
    echo "nothing to see here"
    # TODO: include here doc
    echo "nothing to see here"
}

listIntf() {
    # display a list of interfaces on the guest with value
    # in the first column indicating the interface number
    guest=$1
    intfId=1
    echo "Summary of virtual interfaces on $guest"
    while IFS= ; read -r line
    do
        if [[ "$line" =~ '- ' ]]
        then
            newLine=$(echo $line | sed -e "s/^- /$intfId /g")
            ((intfId++))
            echo $newLine
        else 
            echo $line
        fi
    done < <(virsh domiflist $guest)
}

attachIntf() {
    guest=$1
    ovsNetwork=$2
    vlan=$3

    # step 1: virsh attach-interface 
    echo "creating new interface on $guest on $ovsNetwork"
    virsh attach-interface  --domain $guest \
                            --type network \
                            --model virtio \
                            --source $ovsNetwork \
                            --config

    # get intf number
    intfNum=$(listIntf $guest | grep \
    '[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:' | wc -l)

    # step 2: virt-xml assign vlan
    echo "Assign interface $intfNum on $guest to vlan $vlan"
    virt-xml $guest --edit $intfNum \
                    --network type=network,source=$ovsNetwork,portgroup=$vlan
}

# main loop

# if only one argument is given
if [ $# -eq 1 ]
then
    if [ $1 == '-h' -o $1 == '--help' ]
    then
        usage
    else 
        # display list of interfaces if if only guest argument is given
        listIntf $1
        exit 0
    fi
fi
    
# cases of more than one argument and catch-all
case $2 in
    --attach|-a)
    # we expect 2 parameters after -a
    # we pass 3 arguments to attachIntf()
    if [ $# -eq 4 ]
    then
        attachIntf $1 $3 $4
    else
        echo "$0: -a requires 2 parameters"
    fi ;;

    *)
    usage ;;
esac


#$0 $guest # if guest exists list the interfaces
#$0 $guest -a interface vlan bridge
