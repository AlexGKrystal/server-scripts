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

echo "~~~~~~~~~~~~~~~~~~~~~~
# Top URLs being hit #
~~~~~~~~~~~~~~~~~~~~~~"
grep http $log_file | awk '{print $11}' | sort -n | uniq -c | sort -n | tail

echo "~~~~~~~~~~~~~~~~~~~
# Top User agents #
~~~~~~~~~~~~~~~~~~~"
cat $log_file | awk -F\" '($2 ~ "^GET /"){print $6}' | sort -n | uniq -c | sort -n | tail

echo "~~~~~~~~~~~~~~~~~~
# Top /24 Ranges #
~~~~~~~~~~~~~~~~~~"
cat $log_file | awk '{split($1,a,"."); print a[1] "." a[2] "." a[3]}' | sort | uniq -c | sort -n | awk '$1>0{print $1 " hits from " $2".0/24"}' | tail


echo "~~~~~~~~~~~~~~~~~~
# Top /16 Ranges #
~~~~~~~~~~~~~~~~~~"
cat $log_file | awk '{split($1,a,"."); print a[1] "." a[2]}' | sort | uniq -c | sort -n | awk '$1>0{print $1 " hits from " $2".0.0/16"}' | tail

echo
echo "
~~~~ Data from log file: $log_file ~~~~"
