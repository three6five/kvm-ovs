```
- run the demo script to create the guests
./demo.sh

- check if guests are setup
virsh list --all | grep demo
 -     demo1                          shut off
 -     demo2                          shut off
 -     demo3                          shut off
 -     demo4                          shut off

- build the service chain
TODO: bug: service-chain.sh cannot be run while guests are running (have to be shutoff)
./service-chain.sh ovs-br2 demo1 demo2 demo3 demo4

start guests
for i in {1..4} ; do ./clone.sh demo$i -s ; done

clean-up demo

for i in {1..4} ; do ./clone.sh demo$i -d ; done 
```
