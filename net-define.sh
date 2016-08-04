#!/usr/bin/bash

virsh net-define network.xml
virsh net-start ovs-br3
virsh net-autostart ovs-br3
