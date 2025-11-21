#!/bin/bash
# Usage
# bash -c "$(wget -qO - https://deploy-managed.krystal.uk/scripts/cleanspace.sh)"

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
find /home/ -type f -name "debug.log" -exec rm {} \;
rm -rf /home/cpmove*
find /var/log/atop/ -mtime +2 -exec rm {} \;
find /home/ -name "*.unison.tmp" > /root/unisontmp.log
for u in `cat unisontmp.log`;do rm -rf $u;done
) >/dev/null 2>&1 2>/dev/null & pid=$!

echo "Searching for cPanel Backups over 31 days old..."
find /home/* -maxdepth 1 -name "backup-*.tar.gz" -type f -ctime +31 -exec rm {} \;
echo "cPanel Backups cleaned"
echo "----------------------"
echo -e "${bold}Usage After Cleanup: ${normal}"
sleep 3
df -h
echo -e "\n${bold}Complete... ${normal}\n"
sleep 0.5

# Checking for largest directoies and files
read -p "Do you want to check for largest directories and files? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    FS='/'
    date
    df -h "$FS"
    echo -e "\nLargest Directories:"
    du -hcx --exclude=/proc --exclude=/home/virtfs --exclude=/usr --max-depth=2 "$FS" 2>/dev/null | grep '[0-9]G' | sort -grk 1 | head -15
    echo -e "\nLargest Files:"
    nice -n 19 find "$FS" -mount -type f -print0 2>/dev/null | \
        xargs -0 du -k | sort -rnk1 | head -n20 | \
        awk '{printf "%8d MB\t%s\n",($1/1024),$NF}'
else
    echo "Exiting..."
    exit 0
fi

