#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org
# Installation Squid
IPhome="$1"


echo ""
echo -e "${CRED}         Squid $CEND"
echo ""
	apt-get -y --force-yes install squid3
	service squid3 stop
cp /etc/squid3/squid.conf /etc/squid3/squid.old
sed -i "1i\acl home src $IPhome/32 \n http_access allow home \n forwarded_for off" /etc/squid3/squid.conf
service squid3 start
# Squid
echo "#Squid
iptables -t filter -A INPUT -p tcp --dport 3128 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 3128 -j ACCEPT" >> /etc/init.d/firewall
service firewall restart

echo "Squid proxy port: 3128 <br>" >> /var/www/base/config.txt
