#!/bin/bash

echo "~~~~~~~~~~~~~~~~~
# Checking Solr #
~~~~~~~~~~~~~~~~~"
solr_check=`solr version`
echo $solr_check

echo "~~~~~~~~~~~~~~~~~~~~~~~
# Checking Solr Patch #
~~~~~~~~~~~~~~~~~~~~~~~"
rpm -q --changelog cpanel-dovecot-solr | grep -B1 CPANEL-39455


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~
# Checking ElasticSearch #
~~~~~~~~~~~~~~~~~~~~~~~~~~"
curl -XGET 'http://localhost:9200'

