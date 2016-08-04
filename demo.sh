#!/usr/bin/bash

if [ $# -gt 0 ]
then
    suffix=$1
    guestName="demo${suffix}"
else
    guestName="demo"
fi

guestCount=1
vnf=2
clientTemplate='client-template'
gatewayTemplate='gateway-template'
vnfTemplate='bridge-template'

./clone.sh ${guestName}${guestCount} $clientTemplate
let guestCount=guestCount+1

for (( n=0 ; n<vnf ; n++ ))
do
    ./clone.sh ${guestName}${guestCount} $vnfTemplate
    let guestCount=guestCount+1
done

./clone.sh ${guestName}${guestCount} $gatewayTemplate
let guestCount=guestCount+1
