!/bin/sh

# Empty all rules
iptables -t filter -F
iptables -t filter -X

# Bloc everything by default
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT

# Authorize already established connexions
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

# ICMP (Ping)
#iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
# SSH
#iptables -t filter -A INPUT -p tcp -s 192.168.33.1 --dport 3876 -j ACCEPT
#iptables -t filter -A INPUT -p tcp -s 192.168.33.10 --dport 22 -j ACCEPT
iptables -t filter -A INPUT -p tcp -s 192.168.33.1 --dport 22 -j ACCEPT
#iptables -t filter -A INPUT -p tcp -s 31.44.84.134 -j ACCEPT  #office ip1
#62.76.13.176
# DNS
#iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
#iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT

# HTTP
#iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT

#HTTPS
#iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT

