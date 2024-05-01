#!/bin/sh
# 
# Created by Alex G
# DATE 01/05/2024

# ------------ MySQL Backup START ------------ #
echo "Running MySQL Backup..."
cp /etc/my.cnf /krystal-mysql-upgrade-backup/
whmapi1 configureservice service=mysql enabled=0 monitored=0
mkdir -p /home/0_mysql_backup
rsync -av --delete /var/lib/mysql /krystal-mysql-upgrade-backup/
service mysql stop
rsync -av --delete /var/lib/mysql /krystal-mysql-upgrade-backup/
service mysql start
echo "===================================================="
echo "================ Backup folder view ================"
echo "===================================================="
ls -lah /home/0_mysql_backup/mysql
echo "MySQL MySQL Backup completed - Check above Output looks ok"
whmapi1 configureservice service=mysql enabled=1 monitored=1
# ------------ MySQL Backup END ------------ #

# ------------ MariaDB 10.6 Upgrade START ------------ #
echo "##### !!!! IMPORTANT !!!! #####"
echo "Please verify backups are ok and you are ready to proceed before continuing"
read -p "Do you want to run MySQL upgrade? (y/N): " choice
if [[ "$choice" =~ ^[yY]$ ]]; then
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