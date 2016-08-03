#!/usr/bin/bash
#
#
# Build a service chain - used for demonstration
#
# Given a list of guests the script should auto-define the service chain using
#
# an OVS and vlan numbers
#
# step 1: take a list of guests provided by the user and determine if they exist
#
# step 2: the script should take the an OVS switch as input and determine
#         which VLANs can be used to build the service chain
#
# step 3: use the net-setup.sh script to add the relevant interfaces to the
#         guest machines and assign the correct VLAN as per the define SC
#

set -e


usage() {
    echo "Usage: $0 ovsNetwork guest1 guest2 [guestN]"
    exit 1;
}

fullUsage() {
    echo "nothing to see here"
    # TODO: include here doc
    echo "nothing to see here"
}

addVlan() {

vl=$1

# add the port group
cat <<PORTGROUP >> ovsnet2.xml
  <portgroup name='vlan-$vl'>
    <vlan>
      <tag id='$vl'/>
    </vlan>
  </portgroup>
PORTGROUP

   # may need to restart the network after making changes
}

assignVlan() {
    # create interface on the guest and assign vlan
    # call net-setup script


echo 'assignVlan'

}


# main loop

vlanArr=()
let guests=$#-1
let vlans=guests-1
ovsNetwork=$1

# vlans needed in service chain: N-1
# where N is the number of guests

if virsh net-info $ovsNetwork
then
    echo "OVS network exists"
    # dump xml and check for existing vlans
    # virsh net-dumpxml ovs-br2 | grep '<portgroup'
    
    # find N-1 free VLANs
    for (( v=50 ; v<1000 ; v++ ))
    do
        # <tag id='10'/>
        if virsh net-dumpxml ovs-br2 | grep "tag id='$v'"
        then
            echo "vlan $v in use"
        else
            echo "vlan $v not in use. reserving.."
            # grab vlan and push onto array
            vlanArr+=($v)
            if (( ${#vlanArr[@]} == $vlans ))
            then
                echo "we have enough vlans"
                # end the loop
                break
            fi
        fi
    done
else
    echo "OVS network does not exist"
    #exit 1
fi

echo "guests: $guests"
echo "vlans: $vlans"

# TODO: the section below needs to be looked at :( 
# TODO: net-update network command section xml [--parent-index index] [[--live]
# remove the trailing network XML tag so that we can append our vlan information
sed -i '/\/network/d' ovsnet2.xml

for (( va=0 ; va<=$vlans-1 ; va++ ))
do
    addVlan ${vlanArr[$va]}
done

# put the trailing network XML tag back on the end of the file
echo '</network>' >> ovsnet2.xml

# if network exists
if virsh net-info $ovsNetwork
then
    virsh net-destroy $ovsNetwork
    virsh net-undefine $ovsNetwork
fi

#virsh net-info $ovsNetwork
virsh net-define ovsnet2.xml
virsh net-start $ovsNetwork


#TODO: implement logic to call assignVlan()
