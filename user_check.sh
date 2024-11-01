#!/bin/bash

#Read log file.
echo "enter user:"
read user

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Results of dbgovernor Log #
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
grep $user /var/log/dbgovernor-restrict.log | tail -n 20

echo "~~~~~~~~~~~~
# LVE Info #
~~~~~~~~~~~~"
lveinfo --period=3d --by-fault=any --display-username --user=$user

echo "~~~~~~~~~~~~~
# User Logs #
~~~~~~~~~~~~~"
ls -lhS /home/$user/access-logs/

echo "Enter which log file you wish to check:"
read log_file

echo "#######################################################"
echo "Please note, this log starts at:" `head -1 /home/$user/access-logs/$log_file | awk '{print $4}' | tr -d [`
echo "#######################################################"

echo "~~~~~~~~~~~~~~~~~
# visitors today #
~~~~~~~~~~~~~~~~~"
cat /home/$user/access-logs/$log_file | grep `date '+%e/%b/%G'` | awk '{print $1}' | sort | uniq -c | wc -l

echo "~~~~~~~~~~~~~~~
# top 10 ip's #
~~~~~~~~~~~~~~~"
cat /home/$user/access-logs/$log_file | awk '{print $1}' |  sort -n | uniq -c | sort -n | tail -n 10

echo "
~~~~~~~~~~~~~~~~~~~~~~
# Activity of top IP #
~~~~~~~~~~~~~~~~~~~~~~"
top_ip=`cat /home/$user/access-logs/$log_file | awk '{print $1}' |  sort -n | uniq -c | sort -n | tail -n 1 | awk '{print $2}'`
grep $top_ip /home/$user/access-logs/$log_file | tail -n 5

echo "~~~~~~~~~~~~~~~~~~~~~~
# Top URLs being hit #
~~~~~~~~~~~~~~~~~~~~~~"
grep http /home/$user/access-logs/$log_file | awk '{print $11}' | sort -n | uniq -c | sort -n | tail

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Top User agents #
~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat /home/$user/access-logs/$log_file | awk -F\" '($2 ~ "^GET /"){print $6}' | sort -n | uniq -c | sort -n | tail

echo
echo "
~~~~ Data from log file: /home/$user/access-logs/$log_file ~~~~"
