#!/bin/sh
# 
# Created by Alex G
# DATE 20/03/2024
# Usage
# bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql-disk-space.sh)"

# ------------ Check Disk Space START ------------ #
# Get the size of MySQL directory in bytes
mysql_size=$(du -s /var/lib/mysql | awk '{print $1}')
# Convert size to GB
mysql_size_gb=$(echo "scale=2; $mysql_size / 1024 / 1024" | bc)

# Calculate the required free space (3 times the size of MySQL directory)
required_space=$(echo "$mysql_size * 3" | bc)

# Get available disk space in bytes
available_space=$(df -B 1 /var/lib/mysql | awk 'NR==2 {print $4}')

# Convert available space to GB
available_space_gb=$(echo "scale=2; $available_space / 1024 / 1024 / 1024" | bc)

# Check if there is enough space
if (( available_space >= required_space )); then
    echo "Disk space is AVAILABLE, you may proceed with a backup"
    echo "MySQL directory size: $mysql_size_gb GB"
    echo "Available space on the server: $available_space_gb GB"
else
    echo "!!!! WARNING INSUFFIECIENT SPACE !!!!"
    echo "MySQL directory size: $mysql_size_gb GB"
    echo "Available space on the server: $available_space_gb GB"
    echo "Create a Mounted disk for Backups for more room"
fi
# ------------ Check Disk Space END ------------ #