#!/bin/sh
# 
# Almalinux Managed cPanel / CloudLinux deployment
# 26/04/2023 - Chris
# 

/usr/sbin/clnreg_ks --force
dnf -y install wget 
dnf -y install epel-release

DIR="/usr/local/cpanel/"
if [ -d "$DIR" ]; then
  echo "####### ${DIR} Exists, Installation Cannot Continue!! #######"
  echo
  echo "This script can only be used on a machine that does not already have cpanel installed on it"
  echo
sleep 2
exit 1
else
  echo
  echo "cPanel check GOOD, continuing with installation......"
  echo
fi

dnf clean all
rm -rf /var/cache/yum
cd /root
echo "Now set a hostname, if you select the custom hostname option make sure the selected hostname has DNS pointing to the server IP."
PS3="Select an option: "
select opt in custom nodnsyet; do
        case $opt in
                custom)
                        echo "Enter Hostname:"
                        read -r custhostname
                        hostnamectl set-hostname $custhostname
                        break
                        ;;
                nodnsyet)
                        hostnamectl set-hostname no.dns.yet
                        break
                        ;;
        esac
        break
done
dnf -y update
dnf -y install perl bind-utils net-tools nano chrony bc
systemctl start chronyd
systemctl enable chronyd
sleep 2
echo "Disabling Selinux..."
echo
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo
setenforce 0
echo
echo "Disabling NetworkManager for cPanel installation"
echo 
sleep 2
systemctl disable NetworkManager
systemctl stop NetworkManager
echo
sleep 2
echo 
echo "Installing cPanel, this **WILL** take some time...."
sleep 10
echo
dnf clean all
rm -rf /var/cache/yum
mkdir /root/cpanel_profile/
echo 'mysql-version=10.11' > /root/cpanel_profile/cpanel.config
echo "HTTPUPDATE=fastupdate.krystal.co.uk" >> /etc/cpsources.conf
echo "CPANEL=114" >> /etc/cpupdate.conf
wget --no-check-certificate https://securedownloads.cpanel.net/latest && sh latest
echo
sleep 2
echo
>/var/cpanel/disable_whm_terminal_ui
cd /root/krystal
echo
echo
echo "Adding fixperms.sh to root/scripts..."
echo
mkdir /root/scripts/
cd /root/scripts && wget https://deploy-managed.krystal.uk/scripts/fixperms.sh && chmod a+x fixperms.sh
cd /root/scripts && wget https://deploy-managed.krystal.uk/scripts/fix-phpini.sh && chmod a+x fix-phpini.sh
echo
sleep 1
echo
echo
cd /root/krystal
echo "Securing SSH......"
sleep 10
wget https://deploy-managed.krystal.uk/ssh/alma/sshd_config
rm -rf /etc/ssh/sshd_config
mv sshd_config /etc/ssh/
wget https://deploy-managed.krystal.uk/ssh/authorized_keys
wget https://deploy-managed.krystal.uk/ssh/authorized_keys_krystal
mkdir /root/.ssh/
rm -f /root/.ssh/authorized_keys
mv authorized_keys /root/.ssh/
mv authorized_keys_krystal /root/.ssh/
chmod 600 /root/.ssh/authorized_keys*
sed -i -re 's/#.?CRYPTO_POLICY.*/CRYPTO_POLICY=/' /etc/sysconfig/sshd
service sshd restart
sleep 2
echo
echo "###################"
echo "###################"
echo "SSH port 722 Active, Key Access Only!"
echo "###################"
echo "###################"
sleep 10
echo
echo "Disabling firewalld and installing CSF...."
echo
sleep 2
systemctl disable firewalld
systemctl stop firewalld
wget --no-check-certificate https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
sh install.sh
sleep 2
cd /root/krystal
echo
echo "Configuring custom CSF rules and starting firewall...."
sleep 1
wget https://deploy-managed.krystal.uk/csf/csf.conf
rm -rf /etc/csf/csf.conf
mv csf.conf /etc/csf/
wget https://deploy-managed.krystal.uk/csf/csf.allow
wget https://deploy-managed.krystal.uk/csf/csf.allow.kinclude
rm -rf /etc/csf/csf.allow
mv csf.allow /etc/csf/
mv csf.allow.kinclude /etc/csf/
wget https://deploy-managed.krystal.uk/csf/csf.ignore
wget https://deploy-managed.krystal.uk/csf/csf.ignore.kinclude
rm -rf /etc/csf/csf.ignore
mv csf.ignore /etc/csf/
mv csf.ignore.kinclude /etc/csf
csf -r
sleep 2
echo 
echo
echo "Installing Lets Encrypt"
/scripts/install_lets_encrypt_autossl_provider
sleep 2
echo
echo
yum clean all
echo
echo "Installing pingdom.php check file...."
echo
echo
cd /usr/local/apache/htdocs && wget https://deploy-managed.krystal.uk/pingdom/pingdom.txt && mv /usr/local/apache/htdocs/pingdom.txt /usr/local/apache/htdocs/pingdom.php && chown nobody:nobody /usr/local/apache/htdocs/pingdom.php
sleep 2
rm -rf /var/cache/yum
echo "Deploying CloudLinux Additional Packages"
cd /root/krystal
dnf -y install cagefs
echo "myops" >> /etc/cagefs/exclude/krystal
echo
dnf -y install rsyslog jq oniguruma glances lvemanager
sleep 1
echo
echo "Installing MySQL Governor..."
echo
sleep 5
dnf -y install governor-mysql
/usr/share/lve/dbgovernor/mysqlgovernor.py --mysql-version=mariadb1011
yes|/usr/share/lve/dbgovernor/mysqlgovernor.py --install
sleep 1
cd /root/krystal
wget https://deploy-managed.krystal.uk/mysql/my.cnf && mv /etc/my.cnf /etc/my.cnf.orig && cp /root/krystal/my.cnf /etc/
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
selectorctl --set-current=8.2;
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
echo "### Make sure to remove install scripts from /root/krystal ###"