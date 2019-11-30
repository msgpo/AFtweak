###############################
# Line ending must be LF      #
# . /data/local/iptableson.sh #
###############################

#####################################################
# Interfaces                                        #
# Optional (not needed in higher AFWall+ versions)  #
# It's useful to work with it to block tunnels etc  #
#####################################################
#WAN_IF=eth1
#LAN_IF=eth0
#DMZ_IF=eth2
#LAN_NET=2001:db8:1::/64
#DMZ_NET=2001:db8:2::/64

#####################################################################################################
# IPv6 config                                                                                       #
# Learn how to harden Ipv6                                                                          #
# https://www.ernw.de/download/ERNW_Guide_to_Securely_Configure_Linux_Servers_For_IPv6_v1_0.pdf     #
#####################################################################################################
# IPv6/Privacy Extensions
# http://tools.ietf.org/html/rfc3041
# http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/networking/ip-sysctl.txt;hb=HEAD
echo 2 > /proc/sys/net/ipv6/conf/all/use_tempaddr
echo 2 > /proc/sys/net/ipv6/conf/default/use_tempaddr

####################
#Put this in your config as defaults
#
#net.ipv6.conf.all.use_tempaddr = 2
#net.ipv6.conf.all.temp_valid_lft = 86400
#net.ipv6.conf.all.temp_prefered_lft = 14000
#net.ipv6.conf.all.max_addresses = 64
#net.ipv6.conf.default.use_tempaddr = 2
#net.ipv6.conf.default.temp_valid_lft = 86400
#net.ipv6.conf.default.temp_prefered_lft = 14400
#net.ipv6.conf.default.max_addresses = 64
####################


####################
# Captive Portal   #
####################
# Disable Captive Portal
# CP triggers http://clients3.google.com over UID 1000 and -1
settings put global captive_portal_mode 0
settings put global captive_portal_server 127.0.0.1

####################
# NTP              #
####################
# Turn off default NTP Server
settings put global ntp_server 127.0.0.1

####################
# IPv6 routing     #
####################
# Must be enforced
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

####################
# Wifi scanning    #
####################
# Turn off persitent Wifi scanning
#settings put global wifi_scan_always_enabled 0

#########################
# Location providers    #
#########################
# Allowed location providers via iface
settings put secure location_providers_allowed gps,wifi,network
# Undo
#settings put secure location_providers_allowed ' '

####################
# GPS              #
####################
# High accuracy
#settings put secure location_providers_allowed +gps
# Power savings
#settings put secure location_providers_allowed -gps
# Disable location mode
#settings put secure location_providers_allowed -network

#####################################################################
# Flightmode                                                        #
# Logic:                                                            #
# Put Android to flight mode during Start/shutdown and              #
# start it when the device boots                                    #
#####################################################################
settings put global airplane_mode_on 0
am broadcast -a android.intent.action.AIRPLANE_MODE

####################
# iptable path     #
####################
IPTABLES=/system/bin/iptables
IP6TABLES=/system/bin/ip6tables

####################
# Purge & Flush    #
####################
# Why are some things comment out?
# It's fixed within AFWall+ -> AND...
# ...some providers can't calculate the correct traffic if enabled.

#$IPTABLES -F INPUT
$IPTABLES -F FORWARD
$IPTABLES -t nat -F
$IPTABLES -t mangle -F
$IP6TABLES -F INPUT
$IP6TABLES -F FORWARD
$IP6TABLES -t nat -F
$IP6TABLES -t mangle -F

# Flush/Purge all chains
#$IPTABLES -X
#$IPTABLES -t nat -X
#$IPTABLES -t mangle -X
#$IP6TABLES -X
#$IP6TABLES -t nat -X
#$IP6TABLES -t mangle -X

####################
# Defaults CHAINS  #
####################
# IPv4 connections
# Might b overwritten by GUI (ignore the GUI options)
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP

# IPv6 connections
#$IP6TABLES -P INPUT DROP
$IP6TABLES -P FORWARD DROP
#$IP6TABLES -P OUTPUT DROP

#########################
# DNS & Time            #
# Cloudflare example    #
# 1.0.0.1 / 1.1.1.1     #
# 2606:4700:4700::1111  #
# 2606:4700:4700::100   #
#########################
# Old and flawed
#$IPTABLES -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to 1.1.1.1:53
#$IPTABLES -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to 1.1.1.1:53

# Set a specific dns server for all networks except home WiFi (192.168.150.0/24)
# Best method
#$IPTABLES -t nat -I OUTPUT ! -s 192.168.150.0/24 -p tcp --dport 53 -j DNAT --to-destination 1.1.1.1:53
#$IPTABLES -t nat -I OUTPUT ! -s 192.168.150.0/24 -p udp --dport 53 -j DNAT --to-destination 1.1.1.1:53

# Force a specific dns server for rmnet[*] interface
$IPTABLES -t nat -I OUTPUT -o rmnet+ -p tcp --dport 53 -j DNAT --to-destination 1.1.1.1:53
$IPTABLES -t nat -I OUTPUT -o rmnet+ -p udp --dport 53 -j DNAT --to-destination 1.1.1.1:53

# Route all dns to cloudflare’s DNS
# Test: https://1.1.1.1/dns/
$IP6TABLES -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to [2606:4700:4700::1111]:53
$IP6TABLES -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to [2606:4700:4700::1111]:53
$IP6TABLES -t nat -A POSTROUTING -j MASQUERADE

# Only needed for PI-Hole or AdGuard Home
# Set DNS server in your router, ensure PI-Hole acts then as DNS server.
$IP6TABLES -A INPUT -p tcp --destination-port 443 -j REJECT --reject-with tcp-reset
$IP6TABLES -A INPUT -p udp --destination-port 80 -j REJECT --reject-with icmp6-port-unreachable
$IP6TABLES -A INPUT -p udp --destination-port 443 -j REJECT --reject-with icmp6-port-unreachable

# Force a specific NTP
# https://blog.cloudflare.com/secure-time/
# https://datatracker.ietf.org/doc/draft-ietf-ntp-using-nts-for-ntp/
$IPTABLES -t nat -A OUTPUT -p tcp --dport 123 -j DNAT --to-destination time.cloudflare.com:123
$IPTABLES -t nat -A OUTPUT -p udp --dport 123 -j DNAT --to-destination time.cloudflare.com:123
#$IPTABLES -t nat -A OUTPUT -p udp --dport 1234 -j DNAT --to-destination time.cloudflare.com:1234

##############################
# Wifi Tether                #
##############################
$IPTABLES -I afwall-wifi-tether -p udp -m owner --uid-owner 1052 -m udp --sport 67 --dport 68 -j RETURN
$IPTABLES -I afwall-wifi-tether -p udp -m owner --uid-owner 1052 -m udp --sport 53 -j RETURN
$IPTABLES -I afwall-wifi-tether -p tcp -m owner --uid-owner 1052 -m tcp --sport 53 -j RETURN

##############################
# 3G/4G (HotSpot) Tether     #
##############################
$IPTABLES -A afwall-3g-tether -p tcp -m owner --uid-owner 1014 -m tcp --dport 53 -j RETURN
$IPTABLES -A afwall-3g-tether -p udp -m owner --uid-owner 1014 -m udp --dport 53 -j RETURN
$IPTABLES -A afwall-4g-tether -p tcp -m owner --uid-owner 1014 -m tcp --dport 53 -j RETURN
$IPTABLES -A afwall-4g-tether -p udp -m owner --uid-owner 1014 -m udp --dport 53 -j RETURN

#####################
# Loopback #
#####################
# Allow loopback interface lo
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A "afwall" -o lo -j ACCEPT
$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A OUTPUT -o lo -j ACCEPT

#####################
# Stateful Inspection #
#####################
#$IP6TABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#$IP6TABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
#$IP6TABLES -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#####################
# Anti-Spoofing     #
#####################
#$IP6TABLES -A INPUT ! -i lo -s ::1/128 -j DROP
#$IP6TABLES -A INPUT -i $WAN_IF -s FC00::/7 -j DROP
#$IP6TABLES -A FORWARD -s ::1/128 -j DROP
#$IP6TABLES -A FORWARD -i $WAN_IF -s FC00::/7 -j DROP

########################
# Block tunnel traffic #
########################
#$IP6TABLES -A INPUT -s 2002::/16 -j DROP
#$IP6TABLES -A INPUT -s 2001:0::/32 -j DROP
#$IP6TABLES -A FORWARD -s 2002::/16 -jDROP
#$IP6TABLES -A FORWARD -s 2001:0::/32 -j DROP

# Block IPv6 in IPv4
#$IP6TABLES -A INPUT -p 41 -j DROP
#$IP6TABLES -A FORWARD -p 41 -j DROP

###########################
# # Android Media Server  #
# UID: 1013               #
###########################
$IPTABLES -t nat -A OUTPUT -p tcp -m owner --uid-owner 1013 -j DNAT --to-destination 127.0.0.1:9040
$IPTABLES -t nat -A OUTPUT -p udp -m owner --uid-owner 1013 -j DNAT --to-destination 127.0.0.1:5400


#####################
# Newpipe           #
#####################
npipe=`dumpsys package org.schabi.newpipe | grep userId= | cut -d= -f2 - | cut -d' ' -f1 -`
$IPTABLES -t nat -A OUTPUT -p tcp -m owner --uid-owner $npipe -j DNAT --to-destination 127.0.0.1:9040
$IPTABLES -t nat -A OUTPUT -p udp -m owner --uid-owner $npipe -j DNAT --to-destination 127.0.0.1:5400



##########################################
# Router und Neighbor Discovery #
##########################################
#$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type 133 -j ACCEPT
#$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type 134 -j ACCEPT
#$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type 135 -j ACCEPT
#$IP6TABLES -A INPUT -p icmpv6 --icmpv6-type 136 -j ACCEPT
#$IP6TABLES -A OUTPUT -p icmpv6 --icmpv6-type 133 -j ACCEPT
#$IP6TABLES -A OUTPUT -p icmpv6 --icmpv6-type 134 -j ACCEPT
#$IP6TABLES -A OUTPUT -p icmpv6 --icmpv6-type 135 -j ACCEPT
#$IP6TABLES -A OUTPUT -p icmpv6 --icmpv6-type 136 -j ACCEPT

#####################
# PING #
#####################
# Allow ping requests to the firewall from LAN and DMZ
#$IP6TABLES -A INPUT ! -i $WAN_IF -p icmpv6 --icmpv6-type 128 -j ACCEPT
# Allow ping requests from firewall to LAN and DMZ
#$IP6TABLES -A FORWARD ! -i $WAN_IF -p icmpv6 --icmpv6-type 128 -j ACCEPT

#####################
# Block shit #
#####################
# Facebook
$IPTABLES -A "afwall" -d 31.13.24.0/21 -j REJECT
$IPTABLES -A "afwall" -d 31.13.64.0/18 -j REJECT
$IPTABLES -A "afwall" -d 66.220.144.0/20 -j REJECT
$IPTABLES -A "afwall" -d 69.63.176.0/20 -j REJECT
$IPTABLES -A "afwall" -d 69.171.224.0/19 -j REJECT
$IPTABLES -A "afwall" -d 74.119.76.0/22 -j REJECT
$IPTABLES -A "afwall" -d 103.4.96.0/22 -j REJECT
$IPTABLES -A "afwall" -d 173.252.64.0/18 -j REJECT
$IPTABLES -A "afwall" -d 204.15.20.0/22 -j REJECT
# WhatsApp (per UID)
$IPTABLES -I "afwall" -d 103.4.96.0/22 -m owner --uid-owner 10189 -j ACCEPT
$IPTABLES -I "afwall" -d 204.15.20.0/22 -m owner --uid-owner 10189 -j ACCEPT
$IPTABLES -I "afwall" -d 185.60.216.0/22 -m owner --uid-owner 10189 -j ACCEPT
$IPTABLES -I "afwall" -d 179.60.192.0/22 -m owner --uid-owner 10189 -j ACCEPT
$IPTABLES -I "afwall" -d 173.252.64.0/18 -m owner --uid-owner 10189 -j ACCEPT
$IPTABLES -I "afwall" -d 157.240.0.0/17 -m owner --uid-owner 10189 -j ACCEPT
# Acxiom
$IPTABLES -A "afwall" -d 65.64.16.0/22 -j REJECT
$IPTABLES -A "afwall" -d 65.249.196.0/24 -j REJECT
$IPTABLES -A "afwall" -d 139.61.68.0/22 -j REJECT
$IPTABLES -A "afwall" -d 139.61.74.0/23 -j REJECT
$IPTABLES -A "afwall" -d 139.61.78.0/22 -j REJECT
$IPTABLES -A "afwall" -d 139.61.84.0/22 -j REJECT
$IPTABLES -A "afwall" -d 139.61.96.0/21 -j REJECT
$IPTABLES -A "afwall" -d 139.61.112.0/21 -j REJECT
$IPTABLES -A "afwall" -d 139.61.160.0/23 -j REJECT
$IPTABLES -A "afwall" -d 193.203.192.0/23 -j REJECT
$IPTABLES -A "afwall" -d 198.160.96.0/20 -j REJECT
$IPTABLES -A "afwall" -d 198.160.112.0/21 -j REJECT
$IPTABLES -A "afwall" -d 198.160.124.0/24 -j REJECT
$IPTABLES -A "afwall" -d 198.160.127.0/24 -j REJECT
$IPTABLES -A "afwall" -d 204.107.111.0/24 -j REJECT
$IPTABLES -A "afwall" -d 216.60.222.0/24 -j REJECT

#####################
# Orbot             #
#####################
#$IPTABLES -A "afwall" -d 127.0.0.1 -p tcp --dport 9040 -j ACCEPT
#$IPTABLES -A "afwall" -d 127.0.0.1 -p udp --dport 5400 -j ACCEPT


#####################
# Incoming Traffic #
#####################
# Allow ICMP packets
$IPTABLES -A INPUT -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
$IPTABLES -A INPUT -p icmp -m icmp --icmp-type echo-request -j ACCEPT
$IPTABLES -A INPUT -p icmp -m icmp --icmp-type destination-unreachable -j ACCEPT

# Allow all traffic from an established connection
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Reject all packages during shutdown
$IPTABLES -A INPUT -p tcp -j REJECT --reject-with tcp-reset
$IPTABLES -A INPUT -j REJECT --reject-with icmp-port-unreachable
