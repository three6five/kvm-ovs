```
- requirements
ovs libvirt libvirt-tools kvm
bridge br0 defined on the host for guest connectivity (optional)
RHEL7 or CentOS7 (tested on RHEL7)

- overview
demo1 - client (172.16.100.2)
demo2 - vnf function1 (linux bridge)
demo3 - vnf function2 (linux bridge)
demo4 - gateway (172.16.100.1)

- create ovs bridge called ovs-br3
ovs-vsctl add-br ovs-br3

- define libvirt to ovs network binding
./net-define.sh

- run the demo script to create the guests
TODO: demo requires the guest templates - provide download link
TODO: guest template are large (1.1G each) - one template could be used for all
TODO: ansible to change guest configs instead of individual template images

./demo.sh

- check if guests are setup
virsh list --all | grep demo
 -     demo1                          shut off
 -     demo2                          shut off
 -     demo3                          shut off
 -     demo4                          shut off

- build the service chain
TODO: bug: service-chain.sh cannot be run while guests are running

./service-chain.sh ovs-br3 demo1 demo2 demo3 demo4

- start guests
./guests-start.sh

- test
1. connect to the console of demo1 and ping 172.16.100.1 (u: root p: skipper999)
2. reboot demo2 or demo3. Pings should stop proving that traffic if following
3. demo1->demo2->demo3->demo4

clean-up demo
./demo-clean.sh
```
