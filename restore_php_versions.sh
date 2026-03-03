#!/bin/bash
# restore_php_versions.sh
INPUT_FILE="/root/php_versions_backup.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Backup file not found: $INPUT_FILE"
    exit 1
fi

# Restore .cl.selector files from .bak
while read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    user=$(echo $line | awk '{print $1}')

    if [ -d "/home/$user/.cl.selector" ]; then
        for bak in /home/$user/.cl.selector/*.bak; do
            [ -f "$bak" ] && mv "$bak" "${bak%.bak}"
        done
        # Fix permissions broken from script run as root
        chown -R $user:$user /home/$user/.cl.selector
    fi
done < "$INPUT_FILE"

# Re-apply PHP versions
while read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    user=$(echo $line | awk '{print $1}')
    version=$(echo $line | awk '{print $2}')

    if [ "$version" = "default" ]; then
        echo "Skipping $user (default)"
        continue
    fi

    echo -n "Setting $user to PHP $version... "
    selectorctl --set-user-current=$version -u $user 2>/dev/null && echo "OK" || echo "FAILED"
done < "$INPUT_FILE"

echo "restoring Remote and local  domains"
cat /root/localdomains.bak > /etc/localdomains
cat /root/remotedomains.bak > /etc/remotedomains
echo "restarting Exim"
systemctl restart exim
