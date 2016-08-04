```
- requirements
ovs libvirt libvirt-tools kvm
bridge br0 defined on the host for guest connectivity (optional)

- overview
demo1 - client (172.16.100.2)
demo2 - vnf function1 (linux bridge)
demo3 - vnf function2 (linux bridge)
demo4 - gateway (172.16.100.1)

- create ovs bridge called ovs-br1
ovs-vsctl add-br ovs-br1

- define a network in libvirt
create network.xml
<network>
  <name>ovs-br1</name>
  <forward mode='bridge'/>
  <bridge name='ovs-br1'/>
  <virtualport type='openvswitch'/>
 <portgroup name='vlan-01' default='yes'>
  </portgroup>
</network>

virsh net-define network.xml
virsh net-start ovs-br1
virsh net-autostart ovs-br1

- run the demo script to create the guests
./demo.sh

- check if guests are setup
virsh list --all | grep demo
 -     demo1                          shut off
 -     demo2                          shut off
 -     demo3                          shut off
 -     demo4                          shut off

- build the service chain
TODO: bug: service-chain.sh cannot be run while guests are running
./service-chain.sh ovs-br1 demo1 demo2 demo3 demo4

- start guests
for i in {1..4} ; do ./clone.sh demo$i -s ; done

- test
connect to the console of demo1 and ping 172.16.100.1
reboot demo2 or demo3. Pings should stop proving that traffic if following
demo1->demo2->demo3->demo4

clean-up demo

for i in {1..4} ; do ./clone.sh demo$i -d ; done 
```
