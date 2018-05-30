#!/bin/bash
eth=eth0
proto=udp
port=443

# OpenVPN
iptables -A INPUT -i "$eth" -m state --state NEW -p "$proto" --dport "$port" -j ACCEPT

# Allow TUN interface connections to OpenVPN server
iptables -A INPUT -i tun+ -j ACCEPT

# Allow TUN interface connections to be forwarded through other interfaces
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o "$eth" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$eth" -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT

# NAT the VPN client traffic to the internet
iptables -t nat -A POSTROUTING -s 172.16.10.0/24 -o "$eth" -j MASQUERADE
