#!/bin/sh
# 
# Created by Alex G
# DATE 01/05/2024

# ------------ MySQL Backup START ------------ #
echo "Running MySQL Backup..."
service mysql stop
whmapi1 configureservice service=mysql enabled=0 monitored=0
mkdir -p /home/krystal-mysql-upgrade-backup
rsync -av --delete /var/lib/mysql /home/krystal-mysql-upgrade-backup/
service mysql stop
rsync -av --delete /var/lib/mysql /home/krystal-mysql-upgrade-backup/
service mysql start
echo "===================================================="
echo "================ Backup folder view ================"
echo "===================================================="
ls -lah /home/krystal-mysql-upgrade-backup/mysql
echo "MySQL MySQL Backup completed - Check above Output looks ok"
whmapi1 configureservice service=mysql enabled=1 monitored=1
# ------------ MySQL Backup END ------------ #

# ------------ MariaDB 10.6 Upgrade START ------------ #
echo "##### !!!! IMPORTANT !!!! #####"
echo "Please verify backups are ok and you are ready to proceed before continuing"
read -p "Do you want to run MySQL upgrade? (y/N): " choice
if [[ "$choice" =~ ^[yY]$ ]]; then
    #Upgrading MySQL
    echo "Running MariaDB upgrade"
    /usr/share/lve/dbgovernor/mysqlgovernor.py --mysql-version=mariadb106
    /usr/share/lve/dbgovernor/mysqlgovernor.py --install
    # Backing up cnf and applying new config
    echo "replacing my.cnf (backup in /krystal-mysql-upgrade-backup/)"
    cp /etc/my.cnf /home/krystal-mysql-upgrade-backup/
    curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql103/my.cnf > /etc/my.cnf
    service mysql restart

    echo "Upgrade Complete. MySQL Version:"
    echo "##############################################################################"
    mysql -V
    echo "##############################################################################"
else
    echo "Skipping Upgrade"
fi
# ------------ MariaDB 10.6 Upgrade END ------------ #