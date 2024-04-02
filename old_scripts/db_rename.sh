#!/bin/bash

#Read log file.
echo "enter user:"
read user

#Output existing config
grep "DB_" /home/$user/public_html/wp-config.php

# Get OLD DB Name
echo "enter OLD DB NAME:"
read old_db

echo "enter NEW DB/USER NAME:"
read new_db 

# Move the data.
mysqldump $old_db > /home/$user/db_rename.sql
mysql -u $new_db -p $new_db < /home/$user/db_rename.sql
rm -f /home/$user/db_rename.sql

sed -i "s/${old_db}/${new_db}/g" /home/$user/public_html/wp-config.php
echo "=== Double Check Config ===:"
grep "DB_" /home/$user/public_html/wp-config.php




