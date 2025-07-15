#!/bin/sh
#
# Created by Alex G
# DATE 15/07/2025

# Read log file.
cp_user=$1

if [ -z "$cp_user" ]; then
  echo "Usage: $0 <cp_user>"
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
    jq ".$cp_user.wp_backups | to_entries | map(select(.value | length > 0)) | from_entries" /home/0_backup_freezer/0_seaman/process_user_backups.json
    ;;
  2)
    jq -r ".$cp_user.deep_freeze[] | .file_name, .original_file_path, \"\"" /home/0_backup_freezer/0_seaman/process_user_backups.json
    ;;
  3)
    echo "Enter the date to search (e.g. `tail -n 1 /var/log/seaman.log | awk '{print $1}'`):"
    read -r search_date
    awk -v user="$cp_user" -v date="$search_date" '$1 == date && $4 ~ user' /var/log/seaman.log
    ;;
  *)
    echo "Invalid option. Please enter 1, 2, or 3."
    ;;
esac