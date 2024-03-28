#!/bin/bash
# bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql_log_check.sh)"

#Read log file.
echo "enter user:"
read user


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Latest entries from restrict log #
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
grep $user /var/log/dbgovernor-restrict.log | grep LIMIT_ENFORCED | tail -n 4


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Results of DB Error log #
~~~~~~~~~~~~~~~~~~~~~~~~~~~"
grep $user /var/lib/mysql/mariadb.err | grep 2022 | tail -n 50

echo "~~~~~~~~~~~~~~~~~~~~~~~
# Results of Slow Log #
~~~~~~~~~~~~~~~~~~~~~~~"
grep -A 3 $user /var/lib/mysql/mariadb-slow.log | tail -n 50
