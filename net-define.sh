#!/usr/bin/bash

ovsNetwork=$1

virsh net-define network.xml
virsh net-start $ovsNetwork
virsh net-autostart $ovsNetwork
