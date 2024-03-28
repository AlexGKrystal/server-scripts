#!/bin/bash
# bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql_check.sh)"

#Gets date
today=`date | awk  -F"[ ,]" '{print $1, $3, $2}'`

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DB Governor hits on $today #
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

#Sorts by hits from today.
grep "$today" /var/log/dbgovernor-restrict.log | grep LIMIT_ENFORCED | awk '{print $6}' | sort | uniq -c


