#!/bin/bash

read -rp "Enter a cPanel username or an email address: " user_input

# Check if the input is an email address (i.e. contains @)
if [[ "$user_input" == *"@"* ]]; then
    echo "==============================="
    echo "===== Searching Exim logs ====="
    echo "==============================="
    grep "$user_input" /var/log/exim_mainlog | grep "A=dovecot_"

    # Get cPanel User
    echo ""
    echo "=================================================="
    echo "===== Getting cPanel Owner Details for Email ====="
    echo "=================================================="
    domain=$(echo "$user_input" | awk -F@ '{print $2}')
    cpanel_user=$(/scripts/whoowns "$domain")
    reseller=$(whmapi1 accountsummary user=$cpanel_user | grep owner | awk '{print $2}')
    echo "cPanel account For domain: $cpanel_user"
    echo "Reseller Owner for account: $reseller"
    echo ""

    # Dealing with Compromised pass
    echo "================================================================"
    echo "!!! If Above user is confirmed spamming !!! Reset Password with:"
    new_pass=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20; echo)
    echo "uapi --user=$cpanel_user Email passwd_pop email='$user_input' password='$new_pass'"
    echo ""
else
    # Handle as cPanel username
    echo "========================================"
    echo "===== Searching Exim logs for User ====="
    echo "========================================"
    grep "U=$user_input" /var/log/exim_mainlog
    echo ""
    echo "=========================================="
    echo "===== Full Log for Latest Message ID ====="
    echo "=========================================="
    message_id=$(grep "U=hoursunlock" /var/log/exim_mainlog | tail -n 1 | awk '{print $3}')
    grep $message_id /var/log/exim_mainlog
fi