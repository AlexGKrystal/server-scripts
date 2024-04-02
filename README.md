# Cheat Sheet

## Logs & Users

###### Unsuspend and lock web access to IP address
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/account_unsuspend.sh)"
```

###### Friendly log checker
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/log_check.sh | sh -s LOG_FILE_NAME
```

###### Check user logs for issues regarding resource limits
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/user_check.sh)"
```

## Misc

###### Checking installed modules on a server

```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/cpanel-install-check.sh | sh
```

###### Mass DNS Lookup
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mass-dns.sh)"
```

###### Disable plugins 1 at a time
(run from plugins dir)
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/plugin-disabler.sh)"
```

###### List crons by user
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/list_crons.sh | sh
```

###### Check latest JetBackup log for errors
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/jetbackup-log-check.sh | sh
```

###### Check Disk usage on server
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/disk_usage.sh | sh
```

###### Clear space on server
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/cleanspace.sh | sh
```

###### Installing Elasticsearch 7
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/elasticsearch7-install.sh | sh
```

###### Installing Litespeed
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/ls-install.sh)"
```

###### Litespeed hit checker
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/litespeed-check.sh)"
```
