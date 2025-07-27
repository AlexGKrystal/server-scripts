#!/bin/bash

read -rp "Enter a cPanel username or an email address: " user_input

# Check if the input is an email address (i.e. contains @)
if [[ "$user_input" == *"@"* ]]; then
    echo "===== Searching Exim logs ====="
    grep "$user_input" /var/log/exim_mainlog | grep "A=dovecot_"

    # Get cPanel User
    echo ""
    echo "===== Getting cPanel Owner for Email ====="
    domain=$(echo "$user_input" | awk -F@ '{print $2}')
    owner=$(/scripts/whoowns "$domain")
    echo "cPanel account owner: $owner"
    echo ""

    # Dealing with Compromised pass
    echo "!!! If Above user is confirmed spamming !!! Reset Password with:"
    new_pass=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20; echo)
    echo "uapi --user=$owner Email passwd_pop email='$user_input' password='$new_pass'"
else
    # Handle as cPanel username
    echo "===== Searching Exim logs for User ====="
    grep "U=$user_input" /var/log/exim_mainlog

    echo "===== Full Log for Latest Message ID ====="
    message_id=$(grep "U=hoursunlock" /var/log/exim_mainlog | tail -n 1 | awk '{print $3}')
    grep $message_id /var/log/exim_mainlog
fi