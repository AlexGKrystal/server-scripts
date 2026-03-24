#!/bin/sh
# 
# Created by Alex G
# DATE 24/03/26
#!/bin/bash

# Fetches UptimeRobot IPv4 list and runs `csf -g` against each IP

IP_URL="https://cdn.uptimerobot.com/api/IPv4.txt"

echo "============================================"
echo " UptimeRobot IP CSF Lookup"
echo "============================================"
echo "Fetching IP list from: $IP_URL"
echo ""

# Fetch the IP list
IP_LIST=$(curl -fsSL "$IP_URL")

if [[ $? -ne 0 || -z "$IP_LIST" ]]; then
    echo "ERROR: Failed to fetch IP list from $IP_URL" >&2
    exit 1
fi

# Count IPs
TOTAL=$(echo "$IP_LIST" | grep -c .)
echo "Found $TOTAL IPs. Running csf -g on each..."
echo "============================================"
echo ""

COUNT=0

while IFS= read -r IP; do
    # Skip blank lines or comment lines
    [[ -z "$IP" || "$IP" == \#* ]] && continue

    COUNT=$((COUNT + 1))
    echo "[$COUNT/$TOTAL] Checking: $IP"
    echo "--------------------------------------------"
    csf -g "$IP"
    echo ""

done <<< "$IP_LIST"

echo "============================================"
echo "Done. Checked $COUNT IPs."
echo "============================================"
