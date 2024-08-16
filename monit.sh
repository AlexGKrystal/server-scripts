#!/bin/sh
# 
# Created by Alex G
# DATE 16 August 2024

yum install monit -y

# Update /etc/monitrc to set daemon  10
sed -i 's/set daemon  30/set daemon  10/g' /etc/monitrc

# Create file:
touch /etc/monit.d/iowait.conf

# Add in config
tee /etc/monit.d/iowait.conf >/dev/null <<EOF
set mailserver localhost # Use the local MTA

set mail-format { from: monit@$HOST subject: Monit alert -- $EVENT $SERVICE message: Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION. }

set alert tsfc@krystal.uk

check system $HOST if cpu usage (wait) > 50% for 6 cycles then exec "/usr/bin/pkill -9 lsphp"
EOF

# Start and enable monit service
systemctl start monit
systemctl enable monit

# Output Status
systemctl status monit