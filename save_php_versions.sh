#!/bin/bash
# save_php_versions.sh
OUTPUT_FILE="/root/php_versions_backup.txt"

echo "# PHP version backup - $(date)" > $OUTPUT_FILE
for user in $(ls /var/cpanel/users/); do
    version=$(selectorctl --user-current -u $user 2>/dev/null | awk '{print $1}')
    if [ -n "$version" ]; then
        echo "$user $version" >> $OUTPUT_FILE
    else
        echo "$user default" >> $OUTPUT_FILE
    fi
done

echo "PHP versions Saved to $OUTPUT_FILE"

echo "Backing up remote and local domains"
cat /etc/localdomains > /root/localdomains.bak
cat /etc/remotedomains > /root/remotedomains.bak
