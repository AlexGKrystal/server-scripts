#!/bin/bash

# Get user to enter in Time
echo "Enter Date/hour to check logs:"
# Give example of most recent log entry so user can copy/paste for quick results
echo "example: `tail -n 1 /etc/apache2/logs/access_log | awk '{print substr($4, 2, 14)}'`"
echo "You can also perform a Range: `tail -n 1 /etc/apache2/logs/access_log | awk '{print substr($4, 2, 14)}'`:[4-5]"
# read input
read time_range

truncate=false

if [ $# -gt 0 ]; then
  if [ "$1" == "--truncate" ]; then
    truncate=true
  fi
fi

# Find all log files in the specified directory and its subdirectories, excluding "bytes_log" files
log_files=$(find /var/log/apache2/domlogs/*/ -type f -not -name "*bytes_log")

# Initialize an associative array to store IP counts
declare -A ip_counts

# Loop through each log file
for file in $log_files; do
  if $truncate; then
    # Extract unique IP addresses from the log file within the specified time range using awk and sort
    ips=$(awk -v time_range="$time_range" '$4 ~ "^\\[" time_range {print $1}' "$file" | sort -u)
  else
    ips=$(awk -v time_range="$time_range" '$4 ~ "^\\[" time_range {print $1}' "$file")
  fi

  # Loop through each IP address
  for ip in $ips; do
    # Increment the count for the IP address in the associative array
    ((ip_counts[$ip]++))
  done
done

# Sort the IP addresses by count in descending order
sorted_ips=$(for ip in "${!ip_counts[@]}"; do
  echo "${ip_counts[$ip]} $ip"
done | sort -nr | head -n 30)

# Output the sorted IP addresses and their counts
echo "$sorted_ips"
