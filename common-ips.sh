#!/bin/bash

# Identifies IPs that have accessed the largest number of unique vhosts
# (log files) within a given time frame, excluding the server's own IPs.

# --- Configuration ---
TOP_N=25
ALL_SERVER_IPS=$((hostname -i; hostname -I) | tr ' ' '\n' | sort -u | tr '\n' ' ')

# --- Argument Handling ---
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <hour1> [hour2] [hour3]..."
  echo "   or: $0 '<full_time_string_with_regex>'"
  echo "Example (single hour):    $0 14"
  echo "Example (multiple hours): $0 10 11"
  echo "Example (full string):    $0 '24/Jul/2025:1[0-1]'"
  exit 1
fi

# --- Time Range Processing ---
# Check if the first argument looks like an hour (a number) or a full string.
if [[ "$1" =~ ^[0-9]{1,2}$ ]]; then
  # Mode 1: Processing one or more hour arguments.
  patterns=()
  for hour in "$@"; do
    # Validate that each argument is a number between 0 and 23.
    if ! [[ "$hour" =~ ^([0-9]|1[0-9]|2[0-3])$ ]]; then
      echo "Error: Hour must be a number between 0 and 23. Invalid argument: '$hour'" >&2
      exit 1
    fi
    hour_fmt=$(printf "%02d" "$hour")
    patterns+=("$(date +'%d/%b/%Y'):${hour_fmt}")
  done

  # Join the individual hour patterns with a "|" (OR) for the regex.
  TIME_PATTERN=$(IFS='|'; echo "${patterns[*]}")
  echo "🔎 Searching for top 25 IPs hitting the most vhosts today during hours: $@" >&2

else
  # Mode 2: Processing a single, full string argument (maintains old behavior).
  TIME_PATTERN="$1"
  echo "🔎 Searching for top 25 IPs hitting the most vhosts with time string: '$TIME_PATTERN'" >&2
fi


# --- Main Logic ---
find /var/log/apache2/domlogs/ -type f -not -name "*bytes_log" -print0 | \
  xargs -0 awk -v pattern="$TIME_PATTERN" -v exclude_ips="$ALL_SERVER_IPS" '
    BEGIN {
      # Create an array `exclude_set` containing all server IPs for fast lookup.
      split(exclude_ips, ip_array, " ");
      for (i in ip_array) {
        exclude_set[ip_array[i]] = 1;
      }
    }
    # The regex now checks for any of the patterns provided.
    $4 ~ "^\\[(" pattern ")" && !($1 in exclude_set) {
      print $1, FILENAME
    }
  ' | \
  sort -u | \
  awk '{print $1}' | \
  uniq -c | \
  sort -k1,1nr | \
  head -n "$TOP_N"
