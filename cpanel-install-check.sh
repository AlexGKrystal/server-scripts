#!/bin/bash

echo "#################################"

echo "WHM Nameservers:"
whmapi1 get_nameserver_config | grep " - "
echo

# Check if LiteSpeed is installed
if command -v /usr/local/lsws/bin/lshttpd &> /dev/null; then
    echo "LiteSpeed is installed. <----"
else
    echo "LiteSpeed is not installed."
fi

# Check if Redis is installed
if command -v redis-server &> /dev/null; then
    echo "Redis is installed. <----"
else
    echo "Redis is not installed."
fi

# Check if Node.js is installed
if command -v node &> /dev/null; then
    echo "Node.js is installed. <----"
else
    echo "Node.js is not installed."
fi


# Check if Elasticsearch is installed
version=$(curl -s GET "localhost:9200" | grep -oP '(?<="number" : ")[^"]*')
if [ -n "$version" ]; then
	echo "Elasticsearch version: $version <-----"
else
    echo "Elasticsearch is not installed."
fi

#Checking for FTP services
/scripts/setupftpserver --current


# Check JetBackup5 Destination
echo "JetBackup5 Destination info:"
jetbackup5api -F listDestinations | grep -E 'Ark|username'

# Check installed Perl modules
echo
echo "List of installed Perl modules:"
perl -MExtUtils::Installed -e 'print join("\n", ExtUtils::Installed->new()->modules())'


