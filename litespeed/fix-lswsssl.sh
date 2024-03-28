#!/bin/bash

# This script will check if the LSWS admin SSL has expired for hostname
# and if so, will install a copy of the auto renewed cpanel certificate

arg=$1

if [ ! -e /usr/local/lsws/conf/cert/$(hostname).crt ] || ! (: | openssl x509 -in /usr/local/lsws/conf/cert/$(hostname).crt -checkend 1800) || [ "$arg" == '-f' ]; then

    cpcrtjson=$(/usr/sbin/whmapi1 fetch_service_ssl_components --output=json)
    bundle=$(echo $cpcrtjson | jq -r '.data.services[] | select (.service == "cpanel") | .cabundle')
    certificate=$(echo $cpcrtjson | jq -r '.data.services[] | select (.service == "cpanel") | .certificate')
    key=$(echo $cpcrtjson | jq -r '.data.services[] | select (.service == "cpanel") | .key')

    echo "$key" > /usr/local/lsws/conf/cert/$(hostname).key
    echo -e "$certificate\n$bundle" > /usr/local/lsws/conf/cert/$(hostname).crt

    sed -i.bak -re '/<listener>/,/<\/listener>/{s/^(.+keyFile.+\/conf\/cert\/).+(<\/keyFile>).*$/\1'"$(hostname)"'.key\2/}' /usr/local/lsws/admin/conf/admin_config.xml
    sed -i.bak -re '/<listener>/,/<\/listener>/{s/^(.+certFile.+\/conf\/cert\/).+(<\/certFile>).*$/\1'"$(hostname)"'.crt\2/}' /usr/local/lsws/admin/conf/admin_config.xml

    systemctl restart lsws
    echo "$(hostname) REPLACED"

fi