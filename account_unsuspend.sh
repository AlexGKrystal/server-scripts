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
#### START OF SUPPORT BLOCK DO NOT EDIT ####
############################################
# Please do not remove this block of code  #
# without prior permission from Support    #
############################################
Order Deny, Allow
Deny from all
Allow from $ip_address
############################################
##### End OF SUPPORT BLOCK DO NOT EDIT #####
############################################
EOT

# Fix permissions as file has been changed through root user
chown $user.$user /home/$user/.htaccess

echo "~~~~~~~~~~~~~~~~~~~~~~~~
# Unsuspending Account #
~~~~~~~~~~~~~~~~~~~~~~~~"
/usr/local/cpanel/scripts/unsuspendacct $user


echo "
!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!
You may now edit /home/$user/.htaccess to whitelist additional IPs
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

