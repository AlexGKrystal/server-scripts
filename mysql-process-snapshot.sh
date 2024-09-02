#!/bin/sh
# 
# Created by Alex G
# DATE 02/09/2024
# Run with:
# bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql-process-snapshot.sh)"

# Start logging processes in MySQL, pipe into a log and grab PID for job
echo "Grabbing MySQL processes for 10 seconds"
while true; do mysqladmin processlist | grep -v Sleep | grep _; done > mysql-process-snapshot.log & 
TAIL_PID=$!
# Wait for 10 seconds
sleep 10

# Kill the logging task
echo "Killing logging ..."
kill $TAIL_PID
sleep 2

# Grab Users collumn from log and output top 10 with number of hits
echo "Checking mysql.log for top users..."
cat mysql-process-snapshot.log | awk '{print $4}' |  sort -n | uniq -c | sort -n | tail -n 10
# Clean up log file
rm -f mysql-process-snapshot.log