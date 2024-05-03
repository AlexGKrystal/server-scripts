#!/bin/sh
# 
# Created by Alex G
# DATE 01/05/2024

# ------------ MariaDB repo check START ------------ #
if grep -q "yum.mariadb.org" /etc/yum.repos.d/MariaDB103.repo; then
    echo "Updating URL to use Archived link in in MariaDB103.repo..."
    sed -i 's/yum.mariadb.org/archive.mariadb.org\/yum/g' /etc/yum.repos.d/MariaDB103.repo
    yum clean all
    yum makecache
    echo "MariaDB103.repo updated and yum cache refreshed."
else
    echo "MariaDB103.repo is correct - Skipping modification."
fi
# ------------ MariaDB repo check END ------------ #

# ------------ MySQL repair START ------------ #
read -p "Do you want to run MySQL repair against all Databases? (y/N): " choice
if [[ "$choice" =~ ^[yY]$ ]]; then
    echo "Running MySQL repair..."
    mysqlcheck -A --auto-repair
    echo "MySQL repair completed."
else
    echo "MySQL repair skipped."
fi
# ------------ MySQL repair END ------------ #

# ------------ Check Disk Space START ------------ #
# Get the size of MySQL directory in bytes
mysql_size=$(du -s /var/lib/mysql | awk '{print $1}')
# Convert size to GB
mysql_size_gb=$(echo "scale=2; $mysql_size / 1024 / 1024" | bc)

# Calculate the required free space (3 times the size of MySQL directory)
required_space=$(echo "$mysql_size * 2" | bc)

# Get available disk space in bytes
available_space=$(df -B 1 /var/lib/mysql | awk 'NR==2 {print $4}')

# Convert available space to GB
available_space_gb=$(echo "scale=2; $available_space / 1024 / 1024 / 1024" | bc)

# Check if there is enough space
if (( available_space >= required_space )); then
    echo "Disk space is available, you may proceed with a backup"
    echo "MySQL directory size: $mysql_size_gb GB"
    echo "Available space on the server: $available_space_gb GB"
else
    echo "!!!! WARNING INSUFFIECIENT SPACE !!!!"
    echo "MySQL directory size: $mysql_size_gb GB"
    echo "Available space on the server: $available_space_gb GB"
    echo "Create a Mounted disk for Backups for more room"
fi
# ------------ Check Disk Space END ------------ #
