#!/bin/sh
# 
# Almalinux Managed cPanel / CloudLinux deployment
# 03/08/2021
# 

fstrim -a
service fstrim.timer start
systemctl enable fstrim.timer

yum -y install wget 
dnf -y install epel-release

mkdir /root/krystal
cd /root/krystal && wget https://deploy-managed.krystal.uk/alma/alma-managed-cloudlinux-2.sh

echo "Deploying CloudLinux..."
cd /root/krystal
wget --no-check-certificate https://repo.cloudlinux.com/cloudlinux/sources/cln/cldeploy
#sh cldeploy -i --serverurl http://cl-mirror.krystal.uk/XMLRPC/
sh cldeploy -i --skip-os-check
sleep 2

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

yum clean all
rm -rf /var/cache/yum
cd /root
hostnamectl set-hostname no.dns.yet
yum -y update
yum -y install perl bind-utils net-tools nano chrony bc
service chronyd start
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
yum clean all
rm -rf /var/cache/yum
mkdir /root/cpanel_profile/
echo 'mysql-version=10.3' > /root/cpanel_profile/cpanel.config
echo "HTTPUPDATE=fastupdate.krystal.co.uk" >> /etc/cpsources.conf
wget --no-check-certificate https://securedownloads.cpanel.net/latest && sh latest --skip-cloudlinux
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

echo
echo
echo "#########################################"
echo "#########################################"
echo "#########################################"
echo 
echo "Please reboot, log back in and run the following command"
echo 
echo "sh /root/krystal/alma-managed-cloudlinux-2.sh"
echo 
echo "#########################################"
echo "#########################################"
echo "#########################################"

# reboot run new script

