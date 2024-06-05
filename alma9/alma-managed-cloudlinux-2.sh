#!/bin/sh
#
# Almalinux Managed cPanel / CloudLinux deployment part 2
# 26/04/2023 - Chris
#
echo
echo "Installing Additional Packages"
echo
dnf -y install cagefs
echo "myops" >> /etc/cagefs/exclude/krystal
echo
dnf -y install rsyslog jq oniguruma glances lvemanager
sleep 1
echo
echo "Installing MySQL Governor..."
echo
sleep 5
yum -y install governor-mysql
/usr/share/lve/dbgovernor/mysqlgovernor.py --mysql-version=mariadb1011
yes|/usr/share/lve/dbgovernor/mysqlgovernor.py --install
sleep 1
cd /root/krystal
wget https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql103/my.cnf && mv /etc/my.cnf /etc/my.cnf.orig && cp /root/krystal/my.cnf /etc/
mkdir /var/lib/mysqltmp && chmod 1777 /var/lib/mysqltmp && chown mysql:mysql /var/lib/mysqltmp
systemctl restart mariadb
echo
echo
echo "Initialising CageFS...."
sleep 2
/usr/sbin/cagefsctl --init
echo
echo "Installing alt-php....."
echo
sleep 2
yum -y groupinstall alt-php
yum -y update cagefs lvemanager
echo
echo "Installing kernelcare..."
echo
echo
sleep 2
curl -s https://repo.cloudlinux.com/kernelcare/kernelcare_install.sh | bash
#/usr/sbin/cagefsctl --reinit
echo
echo "Configuring PHP Extensions"
echo
selectorctl --list | cut -d$'\t' -f1 | while read PHPV; do selectorctl --enable-extensions=bcmath,dom,fileinfo,gd,imap,intl,json,mbstring,mcrypt,mysql,mysqli,mysqlnd,pdo,pdo_mysql,pdo_sqlite,phar,posix,sockets,timezonedb,xmlreader,xmlwriter,zip --version=$PHPV; done
selectorctl --list | cut -d$'\t' -f1 | while read PHPV; do [ $(echo '5.2<'$PHPV | bc) == 1 ] && echo "added opcache for PHP $PHPV"; selectorctl --enable-extensions=opcache --version=$PHPV; done
selectorctl --list | cut -d$'\t' -f1 | while read PHPV; do [ $(echo '7.2<'$PHPV | bc) == 1 ] && echo "added nd_mysqli for PHP $PHPV" && selectorctl --enable-extensions=nd_mysqli --version=$PHPV; done
selectorctl --set-current=8.3;
selectorctl --disable-alternative=native
sh /root/scripts/fix-phpini.sh

# APPLY CHANGES TO /etc/cl.selector/php.conf

cd /root/krystal
wget https://deploy-managed.krystal.uk/etc/cl.selector/php.conf && /bin/cp /root/krystal/php.conf /etc/cl.selector/

echo
echo "Configuring EasyApache"
echo
cd /root/krystal
mkdir -p /etc/cpanel/ea4/profiles/custom/
wget https://deploy-managed.krystal.uk/etc/cpanel/ea4/profiles/custom/Krystal20230613.json && /bin/cp /root/krystal/Krystal20230613.json /etc/cpanel/ea4/profiles/custom/Krystal20230613.json
ea_install_profile --install /etc/cpanel/ea4/profiles/custom/Krystal20230613.json
/usr/bin/perl -i.bak -pe ' \
s/^#?\s*lsapi_backend_children\s+[\d]+$/lsapi_backend_children 300/;
s/^#?\s*lsapi_paranoid\s+[\w]+$/lsapi_paranoid On/;
s/^#?\s*lsapi_target_perm\s+[\w]+$/lsapi_target_perm On/;
s/^#?\s*lsapi_mod_php_behaviour\s+[\w]+$/lsapi_mod_php_behaviour Off/;
s/^#?\s*lsapi_terminate_backends_on_exit\s+[\w]+$/lsapi_terminate_backends_on_exit On/;
s/^#?\s*lsapi_backend_accept_notify\s+[\w]+$/lsapi_backend_accept_notify On/;
s/^#?\s*lsapi_backend_max_process_time\s+[\w]+$/lsapi_backend_max_process_time 900/;
' /etc/apache2/conf.d/lsapi.conf 
/usr/local/cpanel/bin/rebuild_phpconf --available | cut -f1 -d: | while read VER; do echo "Setting $VER to lsapi"; /usr/local/cpanel/bin/rebuild_phpconf --${VER}=lsapi --errors --no-users; done
# Extra bits
/usr/sbin/cagefsctl --init
/usr/sbin/cagefsctl --toggle-mode enabled;
/usr/sbin/cagefsctl --enable-all;
echo "multiphp=0" >> /var/cpanel/features/disabled
echo "multiphp_ini_editor=0" >> /var/cpanel/features/disabled
dnf -y install rsyslog
systemctl enable rsyslog
systemctl restart rsyslog
echo
echo "Setting up WHM User..."
sleep 2
cpdefpass=$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 28)
whmapi1 createacct username=kwhm domain=krystal-managed.local featurelist=default quota=10 password=$cpdefpass ip=n cgi=0 hasshell=1 cpmod=jupiter maxftp=unlimited maxsql=unlimited maxpop=unlimited maxlst=unlimited maxsub=unlimited maxpark=unlimited maxaddon=unlimited bwlimit=unlimited language=en useregns=0 reseller=1 forcedns=1 mailbox_format=mdbox mxcheck=local max_email_per_hour=0 max_defer_fail_percentage=1 owner=kwhm
echo
echo "User configured as below:"
echo "Username: kwhm"
echo "Password: $cpdefpass"
echo
cd /root/krystal
mkdir /var/cpanel/acllists/
wget https://deploy-managed.krystal.uk/var/cpanel/acllists/KrystalManaged && /bin/cp /root/krystal/KrystalManaged /var/cpanel/acllists/
whmapi1 --output=jsonpretty setacls reseller=kwhm acllist=KrystalManaged
echo
echo "### Second stage CP-CL Deployment complete ###"
echo "### Make sure to remove install scripts from /root/krystal ###"
