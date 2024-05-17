#!/bin/bash
# Usage
# curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/cleanspace.sh | sh

echo -e "${bold}Usage Before Cleanup: ${normal}"
df -h
sleep 0.5
echo ""
echo -e "~~~~~~~ Cleaning Disk ~~~~~~~"
sleep 1

echo -e "\n${bold}Clearing Orphaned virtfs mounts...${normal}"
/scripts/clear_orphaned_virtfs_mounts --clearall
sleep 0.5
echo -e "\n${bold}Cleaning YUM Caches... ${normal}"
rm -rf /var/cache/yum/*
yum clean all
echo -e "\n${bold}Cleaning Server...${normal} (clearing logs and other temp files) \n"
(
cd /root
find /home/*/.trash/* -exec rm -rf {} \;
find /home/* -name core.[0-9]* -exec rm -vf {} \;
rm -rf cpanel.TMP.work*
rm -rf clamav*
rm -rf spamd*
rm -rf /home/*/tmp/Cpanel_*
rm -rf /usr/local/maldetect/sess/*
rm -rf /home/cprestore/*
rm -rf /mysqlbkp
find /home/ -type f -name "error_log" -exec rm {} \;
rm -rf /home/cpmove*
find /var/log/atop/ -mtime +2 -exec rm {} \;
find /home/ -name "*.unison.tmp" > /root/unisontmp.log
for u in `cat unisontmp.log`;do rm -rf $u;done
) >/dev/null 2>&1 2>/dev/null & pid=$!

echo -e "${bold}Usage After Cleanup: ${normal}"
sleep 3
df -h
echo -e "\n${bold}Complete... ${normal}\n"
sleep 0.5

#Test