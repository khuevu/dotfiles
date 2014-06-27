#!/bin/sh
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Rules, optionally specifiy -i, -o interfaces
# typical incoming network services (for server)
iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 22,80,443 -m state --state RELATED,ESTABLISHED -j ACCEPT

# typical outgoing network services (for client)
iptables -A OUTPUT -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --sports 22,80,443 -m state --state RELATED,ESTABLISHED -j ACCEPT

# allow pings
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# allow outbound DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

# Enable logging of dropped packet
# create a new logging chain
iptables -N LOGGING
iptables -A INPUT -j LOGGING # apply logging chain to the rest of the packet
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOGGING -j DROP

# forward between interfaces
# iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

# Loadblancing
# iptables -A PREROUTING -i eth0 -p tcp --dport 443 -m state --state NEW -m nth --counter 0 --every 3 --packet 0 -j DNAT --to-destination $DEST1
# iptables -A PREROUTING -i eth0 -p tcp --dport 443 -m state --state NEW -m nth --counter 0 --every 3 --packet 1 -j DNAT --to-destination $DEST2
# iptables -A PREROUTING -i eth0 -p tcp --dport 443 -m state --state NEW -m nth --counter 0 --every 3 --packet 2 -j DNAT --to-destination $DEST3

# Prevent DDOS attack
# iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# Port Forwarding
# iptables -t nat -A PREROUTING -p tcp -d $DEST --dport $DEST_PORT -j DNAT --to $MODIFIED_DEST:$MODIFIED_PORT

