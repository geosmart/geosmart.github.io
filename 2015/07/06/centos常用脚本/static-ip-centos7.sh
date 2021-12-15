#!/bin/bash

###############################################################################################################################
#DESCRIPTION: Automated bash script for configuring a static IP RHEL7/CentOS7 installation.
#USAGE: Edit the variables with your network configuration and execute on RHEL7/CentOS7.
#CREATED BY: William Thomas Bland.
###############################################################################################################################

# Declare variables
ipaddr=""       # Set IP Address for this machine
netmask=255.255.255.0      # Set Netmask for this machine
gateway=""      # Set Network Gateway
dns1=""         # Set DNS Server
dns2=""         # Optional - Set 2nd DNS Server - leave blank if not needed
dns3=""         # Optional - Set 3nd DNS Server - leave blank if not needed
hostname=""     # Set Hostname for this machine

# if fail with RTNETLINK answers: File exists Jan 16 22:30:46 localhost.localdomain systemd[1]: network.service: control process exited, code=exited status=1,
## solution1
run 'ps -ef | grep dhc',and kill the dhc process,then run 'systemctl stop network'

## solution2
An IP conflict will also cause this error!
run 'systemctl stop network', then run 'ifup ifcfg-eth0'

###############################################################################################################################

# Stop and disable network manager
systemctl stop NetworkManager
systemctl disable NetworkManager

# Stop network service
systemctl stop network

# Find ethernet device name
eth=$(echo /etc/sysconfig/network-scripts/ifcfg-e* | cut -d- -f3)

# Modify ethernet adapter
echo "DEVICE=\"$eth\"
TYPE=\"Ethernet\"
BOOTPROTO=\"none\"
ONBOOT=\"yes\"
NM_CONTROLLED=\"no\"
IPADDR=\"$ipaddr\"
NETMASK=\"$netmask\"" > /etc/sysconfig/network-scripts/ifcfg-"$eth"

# Set gateway
echo GATEWAY="$gateway" > /etc/sysconfig/network

# Set nameserver
echo $hostname | cut -d. -f2,3 | sed s/^/"search "/ > /etc/resolv.conf
echo nameserver $dns1 >> /etc/resolv.conf

# Add 2nd and/or 3rd nameservers if variables are set
if [ -n "$dns2" ]; then
  echo nameserver $dns2 >> /etc/resolv.conf
  if [ -n "$dns3" ]; then
    echo nameserver $dns3 >> /etc/resolv.conf
  fi
fi

# Set hostname
hostnamectl set-hostname $hostname

# Start network service
systemctl start network

exit 0
