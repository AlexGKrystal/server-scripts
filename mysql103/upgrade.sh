#!/bin/sh
# 
# Created by Alex G
# DATE 01/05/2024

# ------------ MySQL Backup START ------------ #
echo "Stopping MySQL service..."
service mysql stop
echo "Disabing cPanel monitoring of MySQL service..."
whmapi1 configureservice service=mysql enabled=0 monitored=0
echo "Running MySQL Backup..."
rsync -av --delete /var/lib/mysql /home/krystal-mysql-upgrade-backup/
echo "Starting MySQL..."
service mysql start
echo "Enabling cPanel monitoring of MySQL service...(may take a minute)"
whmapi1 configureservice service=mysql enabled=1 monitored=1
echo "===================================================="
echo "================ Backup folder view ================"
echo "===================================================="
ls -lah /home/krystal-mysql-upgrade-backup/mysql
echo "MySQL MySQL Backup completed - Check above Output looks ok"
# ------------ MySQL Backup END ------------ #

# ------------ MariaDB 10.6 Upgrade START ------------ #
echo "##### !!!! IMPORTANT !!!! #####"
echo "Please verify backups are ok and you are ready to proceed before continuing"
while true; do
    read -p "Do you want to run MySQL upgrade? (y/N): " choice
    case "$choice" in
        [Yy]* )
            # Backing up existing my.cnf before upgrade
            cp /etc/my.cnf /home/krystal-mysql-upgrade-backup/
            # Upgrading MySQL
            echo "Running MariaDB upgrade"
            /usr/share/lve/dbgovernor/mysqlgovernor.py --mysql-version=mariadb106
            /usr/share/lve/dbgovernor/mysqlgovernor.py --install
            # Applying new Conf
            echo "Replacing my.cnf (backup in /krystal-mysql-upgrade-backup/)"
            curl -s https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql103/my.cnf > /etc/my.cnf
            echo "Restarting Mysql to apply new conf"
	    service mysql restart

            echo "Upgrade Complete. MySQL Version:"
            echo "##############################################################################"
            mysql -V
            echo "##############################################################################"
            break;;
        [Nn]* )
            echo "Skipping Upgrade"
            break;;
        * )
            echo "Please answer with y or n.";;
    esac
done
# ------------ MariaDB 10.6 Upgrade END ------------ #
