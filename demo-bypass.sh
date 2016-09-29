#!/usr/bin/bash

set -e

OVS_BRIDGE=ovs-br4
PATCH_PORT=patch1
VLAN_SUB=10
VLAN_INT=20
DEBUG=0

if [ $DEBUG == 1 ]
then
    echo "Debug on"
    set -x
fi

vnetUnshut() {
    # TODO: make dynamic
    echo "enabling VNET interfaces.."
    ovs-ofctl mod-port ovs-br4 vnet6 up
    ovs-ofctl mod-port ovs-br4 vnet7 up
    
}

vnetShut() {
    # TODO: make dynamic
    echo "disabling VNET interfaces.."
    ovs-ofctl mod-port ovs-br4 vnet6 down
    ovs-ofctl mod-port ovs-br4 vnet7 down
}

bypassEnable() {

# TODO: shut VM ports if the PTS is blocking traffic

    echo "Detecting Bypass Status.."

# check if patch port already exists on ovs bridge
    if ovs-vsctl show | grep ${PATCH_PORT} > /dev/null 2>&1
    then
        echo "Patch port ${OVS_BRIDGE} ${PATCH_PORT} found. Bypass already enabled? Exiting.."
        exit 1
    else
        echo "Patch port ${OVS_BRIDGE} ${PATCH_PORT} not found. Creating patch.."
    fi

    echo "Calling vnetShut().."
    vnetShut

# create a patch port
    ovs-vsctl add-port ${OVS_BRIDGE} ${PATCH_PORT}-1 > /dev/null 2>&1
    ovs-vsctl add-port ${OVS_BRIDGE} ${PATCH_PORT}-2 > /dev/null 2>&1

# set port type to patch
    ovs-vsctl set interface ${PATCH_PORT}-1 type=patch
    ovs-vsctl set interface ${PATCH_PORT}-2 type=patch

# set patch port peer
    ovs-vsctl set interface ${PATCH_PORT}-1 options:peer=${PATCH_PORT}-2
    ovs-vsctl set interface ${PATCH_PORT}-2 options:peer=${PATCH_PORT}-1

# set vlan tags
    ovs-vsctl set port ${PATCH_PORT}-1 tag=${VLAN_SUB}
    ovs-vsctl set port ${PATCH_PORT}-2 tag=${VLAN_INT}
}

bypassDisable() {

# delete patch ports
    echo "Removing Patch ${OVS_BRIDGE} ${PATCH_PORT}-1"

# check if patch port already exists on ovs bridge
    if ovs-vsctl show | grep ${PATCH_PORT} > /dev/null 2>&1
    then
        echo "Patch port ${OVS_BRIDGE} ${PATCH_PORT} found.."
    else
        echo "Patch port ${OVS_BRIDGE} ${PATCH_PORT} not found. Bypass disabled already?"
        exit 1
    fi

# try and delete the first patch port
    if ovs-vsctl del-port ${OVS_BRIDGE} ${PATCH_PORT}-1
    then
        echo "Successfull removed ${OVS_BRIDGE} ${PATCH_PORT}-1"
    else
        echo "Removing patch ${OVS_BRIDGE} ${PATCH_PORT}-1 failed"
    fi

# try and delete the second patch port
    if ovs-vsctl del-port ${OVS_BRIDGE} ${PATCH_PORT}-2
    then 
        echo "Successfull removed ${OVS_BRIDGE} ${PATCH_PORT}-1"
    else
        echo "Removing patch ${OVS_BRIDGE} ${PATCH_PORT}-1 failed"
    fi

    echo "Calling vnetunshut().."
    vnetUnshut
}

# main

case $1 in
    bypass-enable|-e)
    echo "Enabling Bypass.."
    bypassEnable ;;

    bypass-disable|-d)
    echo "Disabling Bypass.."
    bypassDisable ;;

    *)
    echo "Usage: $0 [bypass-enable|-e] [bypass-disable|-d]" ;;
esac
