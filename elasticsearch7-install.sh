#!/bin/bash

# Install RPM
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#Create repo file
sudo tee /etc/yum.repos.d/elasticsearch.repo >/dev/null <<EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF

# Install elasticsearch
yum install --enablerepo=elasticsearch elasticsearch -y

# Get fix done
echo "-Djava.io.tmpdir=/var/lib/elasticsearch/tmp" > /etc/elasticsearch/jvm.options.d/tmp.options
mkdir /var/lib/elasticsearch/tmp
chown elasticsearch:elasticsearch /var/lib/elasticsearch/tmp

#Enable service
systemctl enable elasticsearch

# Start service
systemctl start elasticsearch

# Add service to startup
chkconfig --add elasticsearch


### Adds Auto restart to the config
CONFIG_FILE="/usr/lib/systemd/system/elasticsearch.service"  # replace with the path to your configuration file

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


# Output Status
echo "
###################################
## Checking ElasticSearch Status ##
###################################
"
curl -X GET "localhost:9200"

# Complete
echo "
####################################
## ElasticSearch install finished ##
##### Add monitoring to MyOps ######
####################################
"
