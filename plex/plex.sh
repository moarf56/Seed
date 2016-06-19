#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org
echo ""
echo -e "${CRED}         Plex $CEND"
echo ""
#Plex
apt-get -y --force-yes install alsa-utils alsa-base alsa-oss oss-compat libasound2-plugins
cd /tmp/
echo "deb http://shell.ninthgate.se/packages/debian wheezy main" >> /etc/apt/sources.list.d/plex.list
wget http://shell.ninthgate.se/packages/shell.ninthgate.se.gpg.key
apt-key add shell.ninthgate.se.gpg.key
apt-get update
apt-get -y --force-yes install plexmediaserver
systemctl enable plexmediaserver
service plexmediaserver restart
chmod +x /etc/init.d/plexmediaserver
chmod 755 /etc/init.d/plexmediaserver
update-rc.d plexmediaserver defaults

echo "#Plex
iptables -t filter -A INPUT -p tcp --dport 8888 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 8888 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 32400 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 32400 -j ACCEPT" >> /etc/init.d/firewall
service firewall restart

echo "Connect your Plex from VNC here: localhost:32400/web <br>" >> /var/www/base/config.txt
