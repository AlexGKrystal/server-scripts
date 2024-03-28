#!/bin/bash

#Read log file.
echo "enter user:"
read user

echo "~~~~~~~~~~~~~~~~~~~~~~~
# Generating temp log #
~~~~~~~~~~~~~~~~~~~~~~~"
grep "/admin" /home/$user/access-logs/* | grep POST > admin_check.log

echo "#######################################################"
echo "Please note, this log starts at:" `head -1 /home/$user/access-logs/admin_check.log | awk '{print $4}' | tr -d [`
echo "#######################################################"

echo "~~~~~~~~~~~~~~~
# top 10 ip's #
~~~~~~~~~~~~~~~"
cat /home/$user/access-logs/admin_check.log | awk '{print $1}' |  sort -n | uniq -c | sort -n | tail -n 10


echo "
~~~~~~~~~~~~~~~~~~~~~~
# Activity of top IP #
~~~~~~~~~~~~~~~~~~~~~~"
top_ip=`cat /home/$user/access-logs/admin_check.log | awk '{print $1}' |  sort -n | uniq -c | sort -n | tail -n 1 | awk '{print $2}'`
grep $top_ip /home/$user/access-logs/admin_check.log | tail -n 5

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Top User agents #
~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat /home/$user/access-logs/admin_check.log | awk -F\" '($2 ~ "^GET /"){print $6}' | sort -n | uniq -c | sort -n | tail

echo
echo "
~~~~ removing temp log file ~~~~"
rm /home/$user/access-logs/admin_check.log
