#!/bin/bash
# restore_php_versions.sh
INPUT_FILE="/root/php_versions_backup.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Backup file not found: $INPUT_FILE"
    exit 1
fi

while read -r line; do
    # Skip comments and empty lines
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

