#!/bin/sh
# 
# Created by Alex G
# DATE 16 August 2024

yum install monit -y

# Update /etc/monitrc to set daemon  10
sed -i 's/set daemon  30/set daemon  10/g' /etc/monitrc

# Comment out lines which start the local web service:
sed -e '/set httpd port 2812/ s/^#*/#/' -i /etc/monitrc
sed -e '/use address localhost/ s/^#*/#/' -i /etc/monitrc
sed -e '/allow localhost/ s/^#*/#/' -i /etc/monitrc
sed -e '/allow admin:monit/ s/^#*/#/' -i /etc/monitrc

# Create file:
touch /etc/monit.d/iowait.conf

# Add in config
cat << EOF > /etc/monit.d/iowait.conf
set mailserver localhost # Use the local MTA

set mail-format { from: monit@\$HOST subject: Monit alert -- \$EVENT \$SERVICE message: Monit \$ACTION \$SERVICE at \$DATE on \$HOST: \$DESCRIPTION. }

set alert tsfc@krystal.uk

check system \$HOST if cpu usage (wait) > 50% for 6 cycles then exec "/usr/bin/pkill -9 lsphp"
EOF


# Start and enable monit service
systemctl start monit
systemctl enable monit

# Output Status
systemctl status monit