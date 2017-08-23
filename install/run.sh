#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- memcached "$@"
fi

# Zabbix 
sed -i -e "s/<ZABBIX_HOSTNAME>/$ZABBIX_HOSTNAME/g" /etc/zabbix/zabbix_agentd.conf
mkdir -p /var/log/zabbix
echo 'Starting Zabbix'
zabbix_agentd

# Memcached
echo 'Starting memcached..'
su -c memcached memcache

