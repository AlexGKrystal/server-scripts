#!/bin/sh

IP_CHECK=$(jetbackup5api -F listDestinations | grep "host:" | awk -F': ' '{print $2}')

declare -A IP_MAP
IP_MAP["172.16.231.33"]="MOVE TO VAULT 1"
IP_MAP["172.16.231.47"]="MOVE TO VAULT 2"
IP_MAP["172.16.231.57"]="185.22.208.27"

TARGET_IPS=("172.16.231.33" "172.16.231.47" "172.16.231.57")

if [[ " ${TARGET_IPS[@]} " =~ " ${IP_CHECK} " ]]; then
  echo "IP $IP_CHECK is Internal."
  echo "WHMLOGIN LINK:"
  whmlogin
  echo
  echo "JetBackup5 Destination info:"
  jetbackup5api -F listDestinations | grep -E 'Ark|username'
  echo
  
  NEW_IP=${IP_MAP[$IP_CHECK]}
  echo "New Destination: $NEW_IP"
  echo
  
  echo "Run this on ark server to whitelist this host"
  echo "echo 'tcp|in|d=722|s=`dig +short myip.opendns.com @resolver1.opendns.com` # Client Server - `hostname`' >> /etc/csf/csf.allow.include && csf -r"
else
  echo "ERROR! Internal IP not detected: $IP_CHECK"
fi