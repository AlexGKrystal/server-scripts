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

###### Check Server wide common IPs
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/common-ips.sh)"
```

###### Check Server wide loogs for common IPs and userAgents (basically same as Friendly log checke)
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/server-log-check.sh)"
```


###### Check top MySQL users (10 second snapshot)
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql-process-snapshot.sh)"
```

###### Mass kvalidator (Assign multiple users to owner kvalidator)
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/kvalidator.sh)"
```

## Maintenance

###### Check latest JetBackup log for errors
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/jetbackup-log-check.sh | sh
```

###### Clear space on server
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/cleanspace.sh | sh
```

###### MariaDB 10.3 to 10.6 Upgrade Script
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mysql-upgrade-script.sh)"
```

## Installs

###### Installing Elasticsearch 7
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/elasticsearch7-install.sh | sh
```

###### Installing Litespeed
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/ls-install.sh)"
```

###### Checking installed modules on a server
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/cpanel-install-check.sh | sh
```

###### Install Monit
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/monit.sh | sh
```


## Misc

###### Mass DNS Lookup
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/mass-dns.sh)"
```

###### Disable plugins 1 at a time (run from plugins directory)
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/plugin-disabler.sh)"
```

###### List crons by user
```
curl https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/list_crons.sh | sh
```

###### Litespeed hit checker
```
bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/litespeed-check.sh)"
```
