#!/bin/bash
# Source: https://outline.k.io/doc/litespeed-config-example-XAtd8FECr8
# run script with bash -c "$(wget -qO - https://r.ioserver.co.uk/ls-install.sh)"

# Configure the worker config:
echo '<IfModule LiteSpeed>
    UserDir disabled
    LSPHP_ProcessGroup on
    LSPHP_Workers 25
</IfModule>' >> /etc/apache2/conf.d/includes/pre_virtualhost_global.conf

# backup conf
cp /usr/local/lsws/admin/conf/admin_config.xml{,.BAK}
# Import new conf
curl https://r.ioserver.co.uk/litespeed/admin_config.xml > /usr/local/lsws/admin/conf/admin_config.xml

# backup conf
cp /usr/local/lsws/conf/httpd_config.xml{,.BAK}
# Import  new conf
curl https://r.ioserver.co.uk/litespeed/httpd_config.xml > /usr/local/lsws/conf/httpd_config.xml

# install Packages
yum install -y jq epel-release oniguruma

# Get update script to update the configs
wget https://r.ioserver.co.uk/litespeed/fix-lswsssl.sh
# run script
sh fix-lswsssl.sh

# Remove script
rm -f fix-lswsssl.sh

# Announce Completed install
echo "
################################
## Litespeed install finished ##
###### Please check this #######
################################
"