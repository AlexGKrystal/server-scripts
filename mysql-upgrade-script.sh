#!/bin/sh
# 
# Created by Alex G
# DATE 18/03/2024
# 
# Usage
# bash -c "$(wget -qO - https://r.ioserver.co.uk/mysql-upgrade-script.sh)"

#!/bin/bash

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
if [[ "$choice" == "y" || "$choice" == "y" ]]; then
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
required_space=$(echo "$mysql_size * 3" | bc)

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

# ------------ MySQL Backup START ------------ # 
read -p "Do you wish to proceed with a backup? [THIS WILL STOP MYSQL DURING THE BACKUP] (y/N): " choice
	if [[ "$choice" == "y" || "$choice" == "y" ]]; then
	    echo "Running MySQL Backup..."
	    mkdir -p /krystal-mysql-upgrade-backup  
		mysqldump --all-databases --routines --triggers > /krystal-mysql-upgrade-backup/dbcopy.sql  
		service mysql stop  
		cp -r /var/lib/mysql/mysql /krystal-mysql-upgrade-backup/  
		service mysql start
		echo "===================================================="
		echo "================ Backup folder view ================"
		echo "===================================================="
		ls -lah /krystal-mysql-upgrade-backup
		echo "============ Contents of Cloned folder ============="
		ls -lah /krystal-mysql-upgrade-backup/mysql
	    echo "MySQL MySQL Backup completed - Check above Output looks ok"
	else
	    echo "MySQL Backup skipped."
	fi
# ------------ MySQL Backup END ------------ #	

# ------------ MariaDB 10.6 Upgrade START ------------ #
echo "##### !!!! IMPORTANT !!!! #####"
echo "Please verify backups are ok and you are ready to proceed before continuing"
read -p "Do you want to run MySQL upgrade? (y/N): " choice
if [[ "$choice" == "y" || "$choice" == "y" ]]; then
	echo "Running MariaDB upgrade"
	/usr/share/lve/dbgovernor/mysqlgovernor.py --mysql-version=mariadb106  
	/usr/share/lve/dbgovernor/mysqlgovernor.py --install
	echo "Upgrade Complete. MySQL Version:"
	echo "##############################################################################"
	mysql -V
	echo "##############################################################################"
else
    echo "Skipping Upgrade"
fi
# ------------ MariaDB 10.6 Upgrade END ------------ #


mysql -V