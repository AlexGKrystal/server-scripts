#!/bin/bash

echo "#################################"

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
if command -v elasticsearch > /dev/null 2>&1; then
    echo "Elasticsearch is installed. <----"
else
    echo "Elasticsearch is not installed."
fi


# Check installed Perl modules
echo
echo "List of installed Perl modules:"
perl -MExtUtils::Installed -e 'print join("\n", ExtUtils::Installed->new()->modules())'


