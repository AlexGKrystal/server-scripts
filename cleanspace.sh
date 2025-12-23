#!/bin/bash

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
## Cleaning Files
cd /root
echo "Emptying Trash..."
find /home -maxdepth 2 -type d -name ".trash" -exec rm -rf {} +
echo "Clearing Core Files..."
find /home/* -name core.[0-9]* -exec rm -vf {} \;
echo "Removing cPanel temp worker files..."
rm -rf cpanel.TMP.work*
echo "Clearing Clamav logs..."
rm -rf clamav*
echo "Clearing Spamd files..."
rm -rf spamd*
echo "Clearing cPanel files from users tmp dirs..."
rm -rf /home/*/tmp/Cpanel_*
echo "maldetect session files..."
rm -rf /usr/local/maldetect/sess/*
echo "Clearing cPanel restore files..."
rm -rf /home/cprestore/*
echo "Clearing MySQL Backup backup folder (often created for upgrades)..."
rm -rf /mysqlbkp
echo "Clearing error_log files..."
find /home/ -type f -name "error_log" -exec rm {} \;
echo "Clearing debug.log files..."
find /home/ -type f -name "debug.log" -exec rm {} \;
echo "Clearing Cpanel move files..."
rm -rf /home/cpmove*
echo "Clearing atop log files older than 2 days..."
find /var/log/atop/ -mtime +2 -exec rm {} \;
echo "Clearing unison.tmp files..."
find /home/ -name "*.unison.tmp" > /root/unisontmp.log
for u in `cat unisontmp.log`;do rm -rf $u;done

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

