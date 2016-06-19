#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org
cmd=(dialog --separate-output --checklist "JRabbitBox" 22 76 16)
options=(1 "LXDE" on
         2 "VNC" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
1)
#Installation LXDE
        apt-get -y --force-yes install xorg lxde-core iceweasel
        chmod 755 /etc/init.d/lxde
        update-rc.d lxde defaults
;;

2)
file="/etc/xdg"
if [ ! -f "$file" ]
then
        apt-get -y --force-yes install xorg lxde-core
        chmod 755 /etc/init.d/lxde
        update-rc.d lxde defaults
fi
# Installation TightVncServer
        apt-get -y --force-yes install tightvncserver

chown -R $rootuser /home/$rootuser/
sudo -u $rootuser tightvncserver :1

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

echo "Connect your LXDE desktop with VNC: $IPserver:5901 <br>" >> /var/www/base/config.txt
;;
  esac
done
