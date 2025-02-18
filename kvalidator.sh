#!/bin/bash
#
# Created by Alex G
# DATE 18/02/2025
# Script is used to create a txt file which can be populated with cPanel cp_accounts
# Accounts are then looped through and assigned to "kvalidator"

# Creates the file and allows user to input list of domains
nano kval_accounts.txt

# Check if the file exists. If not, exit.
if [ ! -f "kval_accounts.txt" ]; then
  echo "Input file 'kval_accounts.txt' not found."
  exit 1
fi

# Loop through each account in the kval_accounts.txt file
while IFS= read -r cp_accounts; do
  whmapi1 --output=jsonpretty modifyacct user=$cp_accounts owner=kvalidator
done < "kval_accounts.txt"

# Cleanup
rm -f kval_accounts.txt
