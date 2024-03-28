#!/bin/bash

#Read log file.
echo "This script will check a URL of your choice for Litespeed hits or misses every 1 minute"
echo "Enter in URL you wish to check:"
read URL

while true
do 
echo `date`
curl -v -S $URL  2>&1 | grep 'x-litespeed-cache\|x-lsadc-cache'
echo "========"
sleep 1m
done





