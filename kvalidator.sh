#!/bin/bash
#
# Created by Alex G
# DATE 18/02/2025
# Script is used to assign all accounts owned by a reseller to kvalidator

# User input for reseller
echo "Enter Reseller user you wish to re-assign to kvalidator"
read RESELLER

# Fetch list of accounts owned by the RESELLER using whmapi1
ACCOUNTS=$(whmapi1 listaccts search=$RESELLER searchtype=owner | grep "user: " | awk '{print $2}')

# Loop through each account and change the owner
for USER in $ACCOUNTS; do
    echo "Assigning $USER to Kvalidator..."
    whmapi1 modifyacct user=$USER owner=kvalidator
done

echo
echo "All Accounts owned by $RESELLER have now been assigned to Kvalidator"
echo
