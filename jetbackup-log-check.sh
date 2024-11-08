#!/bin/sh
# 
# Get the most recent log file where a Backup is run
# Checking log files with "Backup Name" set to get around logs from snapshot cleanup interferring
recent_log=$(grep "Backup Name" /usr/local/jetapps/var/log/jetbackup5/queue/*.log | awk -F':' '{print $1}' | tail -n 1)

# Check if the third line contains "JB Config"
if grep -q "JB Config" $recent_log; then
    # Get the second most recent log file where a Backup is run
    previous_log=$(grep "Backup Name" /usr/local/jetapps/var/log/jetbackup5/queue/*.log | awk -F':' '{print $1}' | tail -n 2 | head -n 1)
    echo "Log File: $previous_log" 
    echo ""
    echo "=========== Errors ==========="
    grep ERROR $previous_log |  tr -d '“,”'
    echo ""
    echo "=========== Users for above Errors ==========="
    #Search for PID, for each one get the cPanel user (second of output, last word)
    for pid in $(grep ERROR $previous_log | awk '{print $5}' | tr -d '[],PID'); do
        username=$(grep $pid $previous_log | head -n 2 | tail -n 1 | awk 'NF>1{print $NF}')
        #output in a nice format
        echo "PID: $pid - User: $username"
    done
else
    # If "JB Config" is not found in the third line, search for "ERROR" in the most recent log file
    echo "Log File: $recent_log" 
    echo ""
    echo "=========== Errors ==========="
    grep ERROR $recent_log |  tr -d '“,”'
    echo ""
    echo "=========== Users for above Errors ==========="
    #Search for PID, for each one get the cPanel user (second of output, last word)
    for pid in $(grep ERROR $recent_log | awk '{print $5}' | tr -d '[],PID'); do
        username=$(grep $pid $recent_log | head -n 2 | tail -n 1 | awk 'NF>1{print $NF}')
        #output in a nice format
        echo "PID: $pid - User: $username"
    done
fi

# generate a WHM login link
echo ""
echo "=========== WHM Login Link ==========="
whmlogin
echo ""
