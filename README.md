# What's this ?
This qjail is a customized version of qjail-5.0 that exists in FreeBSD Ports, making vnet easier to use.  
I hope this function would is applyed original qjail....

# What was changed ?
- The "vnet" column has been added.
- Even if vnet is changed, it retains the IP address.
- IP address is not automatically assigned to vnetized Jail.
- Assign the IP address set by the user to Jail.  
The original qjail is assigned the following IP address according to vnetid.  
```
Host: 10.[vnetid].0.1  
Jail: 10.[vnetid].0.2  
```
However, this qjail assigns the IP address that the user set with the "-4" option to Jail.  

###Caution
When communicating with the host, it is necessary to set the IP address of  
the same network as Jail to the NIC set by "- w" option.

# Install
First install the original qjail, then overwrite this qjail.  

```
# pkg install qjail
# wget --no-check-certificate https://raw.githubusercontent.com/shutingrz/qjail-5.0_vnet_opt/master/src/usr/local/bin/qjail
# wget --no-check-certificate https://raw.githubusercontent.com/shutingrz/qjail-5.0_vnet_opt/master/src/usr/local/bin/qjail.vnet.be
# cp qjail /usr/local/bin/
# cp qjail.vnet.be /usr/local/bin/
```

# Demo
## Jail create
```
# qjail create -4 192.168.10.2 srv
Successfully created  srv
# qjail list


STA JID  NIC IP              vnet?       Jailname
--- ---- --- --------------- ----------- --------------------------------------------------
DS  N/A  vtnet0 192.168.10.2    No          srv
```

↑ This qjail has "vnet?" Column added.

## Jail apply vnet
```
# qjail config -w vtnet0 srv
Successfully enabled vnet.interface for srv
# qjail config -v ipfw srv
Successfully enabled vnet for srv
# qjail list


STA JID  NIC IP              vnet?       Jailname
--- ---- --- --------------- ----------- --------------------------------------------------
DS  N/A  vtnet0 192.168.10.2    vnet|be|ipfw srv
```

↑ This qjail holds the IP address even if vnet is changed.

## Jail start and connect
```
# qjail start srv
Jail successfully started  srv
#
# ifconfig vtnet0 192.168.10.1 alias
# ping 192.168.10.2
PING 192.168.10.2 (192.168.10.2): 56 data bytes
64 bytes from 192.168.10.2: icmp_seq=0 ttl=64 time=0.155 ms
64 bytes from 192.168.10.2: icmp_seq=1 ttl=64 time=0.164 ms
64 bytes from 192.168.10.2: icmp_seq=2 ttl=64 time=0.138 ms
```

# Aappendix 1
IPv6 is also supported.  

```
# qjail config -6 fc00::2 srv
Successful ip change srv
# qjail list


STA JID  NIC IP              vnet?       Jailname
--- ---- --- --------------- ----------- --------------------------------------------------
DS  N/A  vtnet0 192.168.10.2    vnet|be|ipfw srv
             fc00::2


# qjail start srv
Jail successfully started  srv
# ifconfig vtnet0 inet6 fc00::1 alias
# ping6 fc00::2
PING6(56=40+8+8 bytes) fc00::1 --> fc00::2
16 bytes from fc00::2, icmp_seq=0 hlim=64 time=0.246 ms
16 bytes from fc00::2, icmp_seq=1 hlim=64 time=0.259 ms
16 bytes from fc00::2, icmp_seq=2 hlim=64 time=0.282 ms

```
# Appendix 2
Jails belongs to the same network.

```
# qjail create -4 192.168.10.3 srv3
Successfully created  srv3
# qjail config -w vtnet0 srv3
Successfully enabled vnet.interface for srv3
# qjail config -v ipfw srv3
Successfully enabled vnet for srv3
# qjail start srv3
Jail successfully started  srv3
#
# ping 192.168.10.3
PING 192.168.10.3 (192.168.10.3): 56 data bytes
64 bytes from 192.168.10.3: icmp_seq=0 ttl=64 time=0.130 ms
64 bytes from 192.168.10.3: icmp_seq=1 ttl=64 time=0.144 ms
^C
--- 192.168.10.3 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.130/0.137/0.144/0.007 ms
#
# qjail console srv

Welcome to your FreeBSD jail.
srv /root >ping 192.168.10.3
PING 192.168.10.3 (192.168.10.3): 56 data bytes
64 bytes from 192.168.10.3: icmp_seq=0 ttl=64 time=0.207 ms
64 bytes from 192.168.10.3: icmp_seq=1 ttl=64 time=0.170 ms
64 bytes from 192.168.10.3: icmp_seq=2 ttl=64 time=0.173 ms
```
