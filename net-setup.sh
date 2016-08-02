#!/usr/bin/bash

set -e

ovsBridge='ovs-br2'
vlan='vlan-10'
cloneSource='centos-mininst'
guest='br2-vrouter-2'

set -x

echo "Clone $guest from $cloneSource"
virt-clone --connect qemu:///system --original centos-mininst --name $guest --file /vm-images/$guest.img

echo "Edit $guest channel path.."
virt-xml $guest --edit --channel path="/var/lib/libvirt/qemu/channel/target/domain-$guest/org.qemu.guest_agent.0"

echo "Attach interface on $guest to $ovsBridge"
virsh attach-interface --domain $guest --type network --model virtio --source $ovsBridge --config

echo "Attach interface on $guest to $ovsBridge"
virt-xml $guest --edit 2 --network type=network,source=$ovsBridge,portgroup=$vlan
