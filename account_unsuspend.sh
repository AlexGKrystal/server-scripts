#!/bin/bash

#Read log file.
echo "
!!!! PLEASE READ !!!!
Running this script Will:
1. Place a .htaccess (or append) in the users root folder to block access.
2. Unsuspend the account.
"
echo "enter username:"
read user

echo "enter IP to whitelist on site:"
read ip_address

# Will limit account by IP.
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Entering IP based restriction #
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat <<EOT >> /home/$user/.htaccess
############################################
#START OF KRYSTAL SUPPORT BLOCK DO NOT EDIT#
############################################
# Please do not remove this block of code  #
# without prior permission from Krystal    #
############################################
Order Deny, Allow
Deny from all
Allow from $ip_address
############################################
# END OF KRYSTAL SUPPORT BLOCK DO NOT EDIT #
############################################
EOT


echo "~~~~~~~~~~~~~~~~~~~~~~~~
# Unsuspending Account #
~~~~~~~~~~~~~~~~~~~~~~~~"
/usr/local/cpanel/scripts/unsuspendacct $user


echo "
!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!
You may now edit /home/$user/.htaccess to whitelist additional IPs
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

