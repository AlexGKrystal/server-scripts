#!/bin/bash
# Run with bash -c "$(wget -qO - https://raw.githubusercontent.com/AlexGKrystal/server-scripts/main/opensearch-install.sh)"

# Install Repo
curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch/3.x/opensearch-3.x.repo -o /etc/yum.repos.d/opensearch-3.x.repo

#Read password
echo "enter password for opensearch:"
read new_opensearch_password

# Install OpenSearch
env OPENSEARCH_INITIAL_ADMIN_PASSWORD=$new_opensearch_password yum install opensearch -y

# Get tmp Path fix done
mkdir -p /var/lib/opensearch/tmp
chown opensearch:opensearch /var/lib/opensearch/tmp
chmod 750 /var/lib/opensearch/tmp
sed -i 's|^-Djava\.io\.tmpdir=.*|-Djava.io.tmpdir=/var/lib/opensearch/tmp|' /etc/opensearch/jvm.options


#Enable service
systemctl enable opensearch

# Start service
systemctl start opensearch

# Add service to startup
chkconfig --add opensearch


### Adds Auto restart to the config
CONFIG_FILE="/usr/lib/systemd/system/opensearch.service"  # replace with the path to your configuration file

# Check if the configuration file exists
if [[ ! -f $CONFIG_FILE ]]; then
  echo "Configuration file not found!"
  exit 1
fi

# Check if "Restart=always" already exists in the [Service] section
if grep -q "\[Service\]" $CONFIG_FILE; then
  if grep -q "Restart=always" $CONFIG_FILE; then
    echo "Restart=always is already present in the [Service] section."
    exit 0
  fi

  # Use awk to add "Restart=always" under the [Service] section
  awk '/\[Service\]/{print;print "Restart=always";next}1' $CONFIG_FILE > ${CONFIG_FILE}.tmp && mv ${CONFIG_FILE}.tmp $CONFIG_FILE

  echo "Restart=always has been added to the [Service] section."
else
  echo "[Service] section not found in the configuration file."
  exit 1
fi

# Create a Post Update Hook to fix cpanel stopping services after updates
echo "/usr/bin/systemctl restart opensearch" > /usr/local/cpanel/hooks/restart-opensearch.sh
chmod +x /usr/local/cpanel/hooks/restart-opensearch.sh
# registering hook
/usr/local/cpanel/bin/manage_hooks add script /usr/local/cpanel/hooks/restart-opensearch.sh --category=System --event=RPMs::PostTransaction --stage=post --manual

# Output Status
echo "
###################################
## Checking OpenSearch Status ##
###################################
"
curl -X GET https://localhost:9200 -u admin:$new_opensearch_password --insecure

# Complete
echo "
####################################
## OpenSearch install finished ##
####################################
####### Set Memory limits in #######
## /etc/elasticsearch/jvm.options ##
####################################"
