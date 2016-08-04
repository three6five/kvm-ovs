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

editNetwork() {
    # remove the trailing network XML tag so that we can append our vlan information
    netXmlFile=$1
    sed -i '/\/network/d' $netXmlFile

    # add vlan definition to the network file
    for (( va=0 ; va<=$vlans-1 ; va++ ))
    do
        addVlan ${vlanArr[$va]}
    done

    # put the trailing network XML tag back on the end of the file
    echo '</network>' >> $netXmlFile

    # TODO: handle sitations where the network is not started etc.
    # TODO: better to make this a separate function
    #
    # if network exists
    if virsh net-info $ovsNetwork
    then
        virsh net-destroy $ovsNetwork
        virsh net-undefine $ovsNetwork
    fi

    #virsh net-info $ovsNetwork
    virsh net-define ovsnet2.xml
    virsh net-start $ovsNetwork

}

assignVlan() {
    # create interface on the guest and assign vlan
    # call net-setup script
    # ./net-setup.sh guest [-a ovsNetwork vlan]

    # for each guest call ./net-setup and assign vlans
    # guest1: add intf + assign vlan 50 : +1
    # guest2: add intf + assign vlan 50 : +0
    # guest2: add intf + assign vlan 51 : +1
    # guest3: add intf + assign vlan 51 : +0
    # guest3: add intf + assign vlan 52 : +1
    # guest4: add intf + assign vlan 52 : +0
    # guest4: add intf + assign vlan 52 : +1
    # guest5: add intf + assign vlan 52 : +0
    #
    #
    # 50 51 52
    # 1-2 2-3 3-4


    # number of times to loop is N*2-2
    # where N is the number of guests

    #g=$guests*2-2
    gn=1
    vn=0
    flag=0;
    vlArr=("${!1}");
    gnArr=("${!2}");

    for (( vb=1 ; vb<=$guests-1 ; vb++ ))
    do
        # add interface to guest $vb on entering the loop
        # then set flag = 1
        # exit loop
        # -
        # if flag = 1 then add interface to guest $vb set set flag=1
        # if flag = 0 then add another interface to guest $vb
        #
        if [ $flag -eq 0 ]
        then
            flag=1
            #echo "setting flag $flag"
            echo "add interface to guest ${gnArr[$gn]}"
            echo "assign vlan ${vlArr[$vn]}"
            ./net-setup.sh ${gnArr[$gn]} -a $ovsNetwork ${vlArr[$vn]}
            let gn=gn+1
            #let vn=vn+0
        fi

        if [ $flag -eq 1 ]
        then
            flag=0
            #echo "setting flag $flag"
            echo "add interface to guest ${gnArr[$gn]}"
            echo "assign vlan ${vlArr[$vn]}"
            ./net-setup.sh ${gnArr[$gn]} -a $ovsNetwork ${vlArr[$vn]}
            #let gn=gn+0
            let vn=vn+1
        fi
    done

}


# main loop

vlanArr=()
let guests=$#-1
let vlans=guests-1
ovsNetwork=$1
guestName=( "$@" )
echo "foobar: ${guestName[1]}"

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
    exit 1
fi

echo "guests: $guests"
echo "vlans: $vlans"

# the network specified should be based on net-dumpxml $ovsNetwork
editNetwork ovsnet2.xml
assignVlan vlanArr[@] guestName[@]
