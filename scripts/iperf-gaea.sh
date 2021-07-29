#!/bin/bash

sudo ifconfig enp0s31f6 192.168.0.105/24
sudo ifconfig enx00e04c68070b 192.168.1.105/24

# nat source IP 192.168.0.105 -> 192.60.0.105 when going to 192.60.1.105
sudo iptables -t nat -A POSTROUTING -s 192.168.0.105 -d 192.60.1.105 -j SNAT --to-source 192.60.0.105
#  nat inbound 192.60.0.105 -> 192.168.0.105
sudo iptables -t nat -A PREROUTING -d 192.60.0.105 -j DNAT --to-destination 192.168.0.105
# nat source IP 192.168.1.105 -> 192.60.1.105 when going to 192.60.0.105
sudo iptables -t nat -A POSTROUTING -s 192.168.1.105 -d 192.60.0.105 -j SNAT --to-source 192.60.1.105
# nat inbound 192.60.1.105 -> 192.168.1.105
sudo iptables -t nat -A PREROUTING -d 192.60.1.105 -j DNAT --to-destination 192.168.1.105


sudo ip route add 192.60.1.105 dev enp0s31f6
sudo arp -i enp0s31f6 -s 192.60.1.105 00:e0:4c:68:07:0b

sudo ip route add 192.60.0.105 dev enx00e04c68070b
sudo arp -i enx00e04c68070b -s 192.60.0.105 10:e7:c6:80:11:16


ping 192.60.1.105

#iperf3 -B 192.168.1.105 -s
#iperf3 -B 192.168.0.105 -c 192.60.1.105
