#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org
pass="$1"

#Root User
roottest=$(sed '2q;d' /var/www/rutorrent/histo.log)
rootuser="${roottest%%:*}"

#Installation LXDE
        apt-get -y --force-yes install xorg lxde-core iceweasel
        chmod 755 /etc/init.d/lxde
        update-rc.d lxde defaults
# Installation TightVncServer
        apt-get -y --force-yes install tightvncserver expect

	chown -R $rootuser /home/$rootuser/
	tightvncserver -kill :1

#Ecpect
sudo -u $rootuser expect -c "
spawn tightvncserver :1;
expect -nocase \"password:\" {
send \"$pass\r\";
expect -nocase \"Verify:\" {
send \"$pass\r\";
expect -nocase \"Would you like to enter a view-only password \(y\/n\)\?\" {
send \"n\r\";
expect eof }; }; interact } ;
"

if [ ! -f "/etc/init.d/tightvncserver" ]; then
	wget http://www.jrabbit.org/scripts/JRabbitBox/tools/tightvncserver
	mv tightvncserver ~/JRabbitBox/tools/
	cp ~/JRabbitBox/tools/tightvncserver /etc/init.d/tightvncserver
	sed -i "2a\export USER='$rootuser'" /etc/init.d/tightvncserver
        chmod 755 /etc/init.d/tightvncserver
	chmod +x /etc/init.d/tightvncserver
        update-rc.d tightvncserver defaults

# VNC
echo "#VNC
iptables -t filter -A INPUT -p tcp --dport 5900 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 5900 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 5901 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 5901 -j ACCEPT" >> /etc/init.d/firewall
service firewall restart

echo "Connect your LXDE desktop with VNC on port: 5901 <br>" >> /var/www/base/config.txt
fi
