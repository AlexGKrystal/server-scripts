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
