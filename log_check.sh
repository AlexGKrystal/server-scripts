#!/bin/bash

#Read log file.
log_file=$1


echo "#######################################################"
echo "Please note, this log starts at:" `head -1 $log_file | awk '{print $4}' | tr -d [`
echo "#######################################################"

echo "~~~~~~~~~~~~~~~~~~~
# Unique visitors #
~~~~~~~~~~~~~~~~~~~"
cat $log_file | awk '{print $1}' | sort | uniq -c | wc -l

echo "~~~~~~~~~~~~~~~
# top 10 ip's #
~~~~~~~~~~~~~~~"
cat $log_file | awk '{print $1}' |  sort -n | uniq -c | sort -n | tail -n 10


echo "
~~~~~~~~~~~~~~~~~~~~~~
# Activity of top IP #
~~~~~~~~~~~~~~~~~~~~~~"
top_ip=`cat $log_file | awk '{print $1}' |  sort -n | uniq -c | sort -n | tail -n 1 | awk '{print $2}'`
grep $top_ip $log_file | tail -n 5

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Top User agents #
~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat $log_file | awk -F\" '($2 ~ "^GET /"){print $6}' | sort -n | uniq -c | sort -n | tail

echo
echo "
~~~~ Data from log file: $log_file ~~~~"
