#!/bin/sh
# qjail 5.0-vnet opt version.
# author shuto.imai (shu@shutingrz.com)
        
function=$1
jailname=$2
nicname=$3
firewall=$4
vnetid=$5
           
           
start () {  
                    
                  
# Check the hosts network for existing bridge.
# If no bridge yet then create the bridge.
# Add real interface device name to one side of bridge.
#             
bridge=`ifconfig | grep -m 1 bridge | cut -f 1 -d :`
if [ -z ${bridge} ]; then
  ifconfig bridge0 create > /dev/null 2> /dev/null
  ifconfig bridge0 addm ${nicname}
  ifconfig bridge0 up
  # vnet jails will not work unless ip forwarding is enabled.
  sysctl net.inet.ip.forwarding=1 > /dev/null 2> /dev/null
fi           
            
# Do this logic for all vnet jails.
# Assign alias IP number to bridge using vnetid to make it unique per 
# vnet jail.
# The alias IP number is the vnet jails default route ip address.
# Create epair assigning "a" to bridge and "b" to the vnet jail
#             
#ifconfig ${nicname} alias 10.${vnetid}.0.1
ifconfig epair${vnetid} create > /dev/null 2> /dev/null
ifconfig bridge0 addm epair${vnetid}a
ifconfig epair${vnetid}a up
                    
                   
if [ ${firewall} = "ipfw" ]; then
  # Chech to see if selected firewall kernel modules have been loaded.
  if ! kldstat -v | grep -qw ${firewall}; then
    kldload "ipfw.ko"
    kldload "ipdivert.ko"
    echo "ipfw.ko loaded"
  fi       
fi              
                                               
if [ ${firewall} = "pf" ]; then
  # Chech to see if selected firewall kernel modules have been loaded.
  if ! kldstat -v | grep -qw ${firewall}; then
    kldload "pf.ko"
    kldload "pflog.ko"
  fi                
fi        
                               
if [ ${firewall} = "ipf" ]; then
  # Chech to see if selected firewall kernel modules have been loaded.
  if ! kldstat -v | grep -qw ipl; then
    kldload "ipl.ko"
  fi      
fi        
}           
               
          
stop () {       
               
# Disable vnet jails network configuration.
#          
#ifconfig ${nicname} -alias 10.${vnetid}.0.1
ifconfig epair${vnetid}a destroy
          
# If host has no more vnet jails then disable bridge.
#         
epair=`ifconfig | grep -m 1 epair | cut -f 1 -d :`
if [ -z ${epair} ]; then
  ifconfig bridge0 destroy
fi            
}            
                
[ "${function}" = "start" ]   && start   $*  && exit 0
[ "${function}" = "stop" ]    && stop    $*  && exit 0
              
