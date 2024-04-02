#!/bin/bash

# Creates the file and allows user to input list of domains
nano domains.txt

# Input file containing domains
input_file="domains.txt"

# Output file to store IP addresses
output_file="dns-results.txt"

# Get records Type from User
echo "Enter record Type we're looking up"
read type

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "Input file '$input_file' not found."
  exit 1
fi

# Remove the output file if it already exists
if [ -f "$output_file" ]; then
  rm "$output_file"
fi

# Loop through each domain in the input file
while IFS= read -r domain; do
  # Use dig to get the IP address and append it to the output file
  ip_address=$(dig $type +short "$domain")
  echo "Domain: $domain $type: $ip_address" >> "$output_file"
  echo "======================" >> "$output_file"
done < "$input_file"

echo "DNS Queries have been completed and are stored in '$output_file'."

# Cleanup
rm -f domains.txt
