#!/bin/sh
# 
# Created by Alex G
# DATE 21/11/24
# This script will build an RPM from the latest redis stable tar file.

# !!! Requirements !!!
# Make directories: mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
# Install requirements: dnf install rpm-build gcc make tcl wget -y

# Getting the Latest Stable
wget http://download.redis.io/redis-stable.tar.gz -O ~/rpmbuild/SOURCES/redis-stable.tar.gz

# Grab the version from the tar file
redis_version=`zgrep -a "redis-stable/src/version.h" ~/rpmbuild/SOURCES/redis-stable.tar.gz | awk -F'"' '/#define REDIS_VERSION/ {print $2}'`

# Build spec sheet with redis version
cat <<EOF > ~/rpmbuild/SPECS/redis.spec
Name:           redis
Version:        stable
Release:        1%{?dist}
Summary:        Redis is an open source key-value store

License:        BSD
URL:            https://redis.io
Source0:        redis-stable.tar.gz

BuildRequires:  gcc, make, tcl
Requires:       systemd

%description
Redis is an open source, in-memory data structure store, used as a database, cache, and message broker.

%prep
%setup -q -n redis-stable

%build
make %{?_smp_mflags}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/libexec/redis
mkdir -p %{buildroot}/usr/lib/systemd/system
mkdir -p %{buildroot}/etc/redis

# Install binaries
install -m 0755 src/redis-server %{buildroot}/usr/bin/
install -m 0755 src/redis-cli %{buildroot}/usr/bin/

# Install configuration
install -m 0644 redis.conf %{buildroot}/etc/redis/redis.conf

# Install systemd service
cat <<'SERVICE' > %{buildroot}/usr/lib/systemd/system/redis.service
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
ExecStart=/usr/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/bin/redis-cli shutdown
Restart=always
User=redis
Group=redis

[Install]
WantedBy=multi-user.target
SERVICE

%files
/usr/bin/redis-server
/usr/bin/redis-cli
/usr/lib/systemd/system/redis.service
/etc/redis/redis.conf

%changelog
* Wed Nov 21 2024 Your Name <youremail@example.com> - 6.2.11-1
- Initial RPM package for Redis
EOF

# Build RPM
rpmbuild -ba ~/rpmbuild/SPECS/redis.spec

echo
# Output version since we now have a consistent name "stable"
echo "##########################################"
echo "RPM build complete for redis VERSION $redis_version"
echo "##########################################"
# Output file list, we can always do something else with this later instead, such as a move or git push.
# e.g. mv ~/rpmbuild/RPMS/x86_64/redis-stable*.rpm ~/git/redis-stable-latest.rpm
echo "RPM files in ~/rpmbuild/RPMS/x86_64/"
ls -lh ~/rpmbuild/RPMS/x86_64/
