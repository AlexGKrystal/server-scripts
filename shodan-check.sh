#!/bin/sh
#
# Created by Alex G
# DATE 02/09/2025

# Read log file.
cp_user=$1

if [ -z "$cp_user" ]; then
  echo "Run script with user: /root/scripts/shodan-check.sh cp_user"
  exit 1
fi

echo "#################################"
echo "# Backup Archive / pruner check #"
echo "#################################"
echo ""
echo "Please enter one of the following options:"
echo "1. What Backup files and what type were found on the last scan?"
echo "2. List Backup file names in the user's deep freeze with full original paths"
echo "3. Show action log for this user for a specific date"
echo "Option:"
read -r option

case "$option" in
  1)
    echo "==== Wordpress Files Found ===="
    jq --arg user "$cp_user" '.[$user].wp_backups | to_entries | map(select(.value | length > 0)) | from_entries' /home/0_shodan_backup_manager/0_shodan/shodan_database.json
    echo "==== cPanel Backup files Found ===="
    jq --arg user "$cp_user" '.[$user].cpanel_backups' /home/0_shodan_backup_manager/0_shodan/shodan_database.json
    ;;
  2)
    jq --arg user "$cp_user" '.[$user].cpanel_backups' /home/0_shodan_backup_manager/0_shodan/shodan_database.json
    ;;
  3)
    echo "Enter the date to search (e.g. Todays date: `tail -n 1 /var/log/shodan.log | awk '{print $1}'`):"
    read -r search_date
    awk -v user="$cp_user" -v date="$search_date" '$1 == date && $4 ~ user' /var/log/shodan.log
    ;;
  *)
    echo "Invalid option. Please enter 1, 2, or 3."
    ;;
esac
