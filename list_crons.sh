#!/bin/bash
cd /var/spool/cron
ls -1 > /root/userscronjobs.txt
for i in `cat /root/userscronjobs.txt`
 do
  echo "###### For the user $i ######" >> /root/cron_list.txt
  echo "" >> /root/cron_list.txt
  cat $i >> /root/cron_list.txt
  echo "" >> /root/cron_list.txt
  echo "###########################" >> /root/cron_list.txt
  echo "" >> /root/cron_list.txt
 done

# View file
cat /root/cron_list.txt

#Cleanup
rm -f /root/cron_list.txt
rm -f /root/userscronjobs.txt
