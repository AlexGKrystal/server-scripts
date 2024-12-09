#!/bin/sh
# 
# Created by Alex G
# DATE 09/12/2024

# Get IP from Config
IP_CHECK=`jetbackup5api -F listDestinations | grep host | awk -F': ' '{print $2}'`

# Define the IPs to check against
TARGET_IPS=("172.16.231.33" "172.16.231.47" "172.16.231.57")

# Check if the IP matches any of the target IPs
if [[ " ${TARGET_IPS[@]} " =~ " ${IP_CHECK} " ]]; then
  echo "IP $IP_CHECK is a Internal."
  echo "WHMLOGIN LINK:"
  whmlogin
  echo
  echo "Run this on ark server ti whitelist this host"
  echo "echo 'tcp|in|d=722|s=`ip addr show dev eth0 | grep inet | head -n 1 | awk '{print $2}' | cut -d'/' -f1` # Client Server - `hostname`' >> /etc/csf/csf.allow.include && csf -r"
else
  echo "ERROR! Internal IP not detected: $IP_CHECK"
fi

whmlogin;echo;echo "echo 'tcp|in|d=722|s=`ip addr show dev eth0 | grep inet | head -n 1 | awk '{print $2}' | cut -d'/' -f1` # Client Server - `hostname`' >> /etc/csf/csf.allow.include && csf -r"