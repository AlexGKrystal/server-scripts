#!/bin/bash
# Source: https://outline.k.io/doc/litespeed-config-example-XAtd8FECr8
# run script with bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/ls-install.sh)"

# Configure the worker config:
echo "Configuring the worker config..."
echo '<IfModule LiteSpeed>
    UserDir disabled
    LSPHP_ProcessGroup on
    LSPHP_Workers 25
</IfModule>' >> /etc/apache2/conf.d/includes/pre_virtualhost_global.conf

# backup conf
echo "Backing up existing admin config..."
cp /usr/local/lsws/admin/conf/admin_config.xml{,.BAK}
# Import new conf
echo "importing new config..."
curl -s https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/litespeed/admin_config.xml > /usr/local/lsws/admin/conf/admin_config.xml

# backup conf
echo "Backing up existing http config..."
cp /usr/local/lsws/conf/httpd_config.xml{,.BAK}
# Import  new conf
echo "Importing new http config..."
curl -s https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/litespeed/httpd_config.xml > /usr/local/lsws/conf/httpd_config.xml

# install Packages
echo "Installing packages..."
yum install -y jq epel-release oniguruma

# Get update script to update the configs
echo "Getting SSL fix script..."
curl -s https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/litespeed/fix-lswsssl.sh > fix-lswsssl.sh
# run script
echo "Running SSL fix script..."
sh fix-lswsssl.sh

# Remove script.
echo "Deleting SSL fix script..."
rm -f fix-lswsssl.sh

# Running update whicvh usually fixes any issues during install
echo "running update script to fix any issues..."
/usr/local/lsws/admin/misc/lsup.sh -f

#Switching to LS from Apache
echo "Switching to LS..."
/usr/local/lsws/admin/misc/cp_switch_ws.sh lsws

# Announce Completed install
echo "
################################
## Litespeed install finished ##
###### Please check this #######
################################
"
