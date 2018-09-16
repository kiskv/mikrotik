#Set bandwidth of the interface
:local interfaceBandwidth 100M

# address-lists
:for i from=1 to=10 do={/ip firewall address-list add list=WoT address=("login.p"."$i".".worldoftanks.net")}
:for i from=1 to=10 do={/ip firewall address-list add list=XBOX address=("xbox.com")}
:for i from=1 to=10 do={/ip firewall address-list add list=Battle address=("eu.battle.net")}


#
/ip firewall mangle
# prio_1 DNS, ICMP, ACK
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=icmp
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=tcp port=53
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=udp port=53
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=tcp tcp-flags=ack packet-size=0-123
# prio_2 SIP
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 dscp=40                                     
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 dscp=46
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 protocol=udp port=5060,5061
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 protocol=udp port=5060,5061
# prio_3 SSH и игры
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 protocol=tcp port=22,23,2244,3724,1119,1120,4000,6112,6113,6114,3074,6881
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 protocol=udp port=88,3074,500,3544,4500,6881
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 src-address-list=WoT
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 dst-address-list=WoT
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 src-address-list=XBOX
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 dst-address-list=XBOX
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 src-address-list=Battle
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 dst-address-list=Battle
# prio_4 RDP и HTTP/HTTPS 
    add chain=prerouting action=mark-packet new-packet-mark=prio_4 protocol=tcp port=3389
    add chain=prerouting action=mark-packet new-packet-mark=prio_4 protocol=tcp port=80,443
    add chain=prerouting action=mark-packet new-packet-mark=prio_4 protocol=udp port=52260

/queue tree add max-limit=$interfaceBandwidth name=QoS_global parent=global priority=1
:for indexA from=1 to=4 do={
   /queue tree add \ 
      name=( "prio_" . "$indexA" ) \
      parent=QoS_global \
      priority=($indexA) \
      queue=default \
      packet-mark=("prio_" . $indexA) \
      comment=("Priority " . $indexA . " traffic")
}
/queue tree add name="prio_5" parent=QoS_global priority=5 queue=ethernet-default \
    packet-mark=no-mark comment="Priority 5 traffic"

/ip firewall mangle
# prio_1 DNS, ICMP, ACK
    add chain=prerouting action=set-priority new-priority=7 protocol=icmp
    add chain=prerouting action=set-priority new-priority=7 protocol=tcp port=53
    add chain=prerouting action=set-priority new-priority=7 protocol=udp port=53
    add chain=prerouting action=set-priority new-priority=7 protocol=tcp tcp-flags=ack packet-size=0-123
# prio_2 SIP
    add chain=prerouting action=set-priority new-priority=6 dscp=40                                     
    add chain=prerouting action=set-priority new-priority=6 dscp=46
    add chain=prerouting action=set-priority new-priority=6 protocol=udp port=5060,5061
    add chain=prerouting action=set-priority new-priority=6 protocol=udp port=5060,5061
# prio_3 SSH, Telnet и игры
    add chain=prerouting action=set-priority new-priority=5 protocol=tcp port=22,23,2244,3724,1119,1120,4000,6112,6113,6114,3074,6881
    add chain=prerouting action=set-priority new-priority=5 protocol=udp port=88,3074,500,3544,4500,6881
    add chain=prerouting action=set-priority new-priority=5 src-address-list=WoT
    add chain=prerouting action=set-priority new-priority=5 dst-address-list=WoT
    add chain=prerouting action=set-priority new-priority=5 src-address-list=XBOX
    add chain=prerouting action=set-priority new-priority=5 dst-address-list=XBOX
    add chain=prerouting action=set-priority new-priority=5 src-address-list=Battle
    add chain=prerouting action=set-priority new-priority=5 dst-address-list=Battle
# prio_4 RDP и HTTP/HTTPS 
    add chain=prerouting action=set-priority new-priority=3 protocol=tcp port=3389
    add chain=prerouting action=set-priority new-priority=3 protocol=udp port=52260

