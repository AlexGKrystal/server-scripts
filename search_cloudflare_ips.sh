#!/bin/bash
#IPv4 Addresses
# Get latest IPv4 IPs from CF
curl -s https://www.cloudflare.com/ips-v4/# > cf-ipv4-temp.txt

# Run through Listed IPs anc check for blocks
echo "!!! Checking IPv4 Addresses being Blocked !!!"
while read ip; do
  csf -g "${ip}"
done <cf-ipv4-temp.txt

# Clean up temp file
rm -f cf-ipv4-temp.txt

#IPv6 Addresses
# Get latest IPv6 IPs from CF
curl -s https://www.cloudflare.com/ips-v6/# > cf-ipv6-temp.txt

# Run through Listed IPs anc check for blocks
echo "!!! Checking IPv6 Addresses being Blocked !!!"
while read ip; do
  csf -g "${ip}"
done <cf-ipv6-temp.txt

# Clean up temp file
rm -f cf-ipv6-temp.txt