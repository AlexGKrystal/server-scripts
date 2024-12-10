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
  echo "JetBackup5 Destination info:"
  jetbackup5api -F listDestinations | grep -E 'Ark|username'
  echo
  echo "Run this on ark server to whitelist this host"
  echo "echo 'tcp|in|d=722|s=`dig +short myip.opendns.com @resolver1.opendns.com` # Client Server - `hostname`' >> /etc/csf/csf.allow.include && csf -r"
else
  echo "ERROR! Internal IP not detected: $IP_CHECK"
fi