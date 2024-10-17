#!/bin/bash

# Get user to enter in Time
echo "Enter Date/hour to check logs:"
# Give example of most recent log entry so user can copy/paste for quick results
echo "example: `tail -n 1 /etc/apache2/logs/access_log | awk '{print substr($4, 2, 14)}'`"
# read input
read time


# get time for all logs into a single file
grep "$time" /usr/local/apache/logs/domlogs/*-ssl_log > ~/overview_log_temp.log

echo "~~~~~~~~~~~~~~~~~~~
# Unique visitors #
~~~~~~~~~~~~~~~~~~~"
cat ~/overview_log_temp.log | awk '{print $1}' | sort | uniq -c | wc -l

echo "~~~~~~~~~~~~~~~
# top 40 ip's #
~~~~~~~~~~~~~~~"
cat ~/overview_log_temp.log | awk '{print $1}' | awk -F':' '{print $2}' |  sort -n | uniq -c | sort -n | tail -n 40

echo "
~~~~~~~~~~~~~~~~~~~~~~
# Activity of top IP #
~~~~~~~~~~~~~~~~~~~~~~"
top_ip=`cat ~/overview_log_temp.log | awk '{print $1}' |  sort -n | uniq -c | sort -n | tail -n 1 | awk '{print $2}'`
grep $top_ip ~/overview_log_temp.log | tail -n 5

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Top User agents #
~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat ~/overview_log_temp.log | awk -F\" '($2 ~ "^GET /"){print $6}' | sort -n | uniq -c | sort -n | tail -n 20

# User puput to confirm log location and cleanup command
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~
raw log file in ~/overview_log_temp.log
remove with: rm -f ~/overview_log_temp.log
~~~~~~~~~~~~~~~~~~~~~~~~~~~"

