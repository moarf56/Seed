#!/bin/bash

# variables couleurs
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

clear
echo -e "${CBLUE}        ______        __    __    _ __  $CEND "
echo -e "${CBLUE}       / / __ \____ _/ /_  / /_  (_) /_ $CEND "
echo -e "${CBLUE}  __  / / /_/ / __ \/ __ \/ __ \/ / __/ $CEND "
echo -e "${CBLUE} / /_/ / _, _/ /_/ / /_/ / /_/ / / /_   $CEND "
echo -e "${CBLUE} \____/_/ |_|\__,_/_.___/_.___/_/\__/   $CEND "
echo -e "${CBLUE}     ____                               $CEND "
echo -e "${CBLUE}    / __ )____  _  __                   $CEND "
echo -e "${CBLUE}   / __  / __ \| |/_/                   $CEND "
echo -e "${CBLUE}  / /_/ / /_/ />  <                     $CEND "
echo -e "${CBLUE} /_____/\____/_/|_|                     $CEND "
echo -e "${CBLUE}                                        $CEND "
echo -e "${CGREEN} http://www.jrabbit.org $CEND "
echo -e "${CGREEN} Email: contact@jrabbit.org $CEND "
echo -e "${CGREEN} Author: warezcmpt $CEND "
echo -e "${CGREEN} Version: 2.0 $CEND "

#Test version Debian
VERSION1=`sed -n 1p /etc/debian_version`
VERSION=${VERSION1:0:1}

# controle droits utilisateur
var2=`sed -n 2p ~/language`
if [ $(id -u) -ne 0 ]; then
echo -e "${CRED} Sorry only root user can install JRabbitBox $CEND"
exit 1
fi


if [ $VERSION  == "8" ] ; then

#Test bonobox
folder="/var/www/base"
if [ ! -d "$folder" ] ; then
			apt-get update -y
			apt-get upgrade -y
			apt-get install git-core -y
			cd /tmp
			git clone https://github.com/exrat/rutorrent-bonobox
			cd rutorrent-bonobox
			sed -i 's/reboot/#reboot/g' bonobox.sh
			sed -i 's/source-#reboot/source-reboot/g' bonobox.sh
			chmod a+x bonobox.sh
			source ./bonobox.sh
fi

#Variables
#IP Server
IPserver=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
	if [ "$IPserver" = "" ]; then
	IPserver=$(wget -qO- ipv4.icanhazip.com)
	fi

#IP Home
IPhome=($SSH_CLIENT)

#Main user & mail
if [ -f "/var/www/rutorrent/histo.log" ] ; then
	#Root User
	roottest=$(sed '2q;d' /var/www/rutorrent/histo.log)
	rootuser="${roottest%%:*}"
	#Email
	email=$(sed '1q;d' /var/www/rutorrent/histo.log)
elif [ -f "/var/www/rutorrent/histo_ess.log" ] ; then
	#Root User
	roottest=$(sed '2q;d' /var/www/rutorrent/histo_ess.log)
	rootuser="${roottest%%:*}"
	#Email
	email=$(sed '1q;d' /var/www/rutorrent/histo_ess.log)
else
echo -e "${CRED} OUPS something went wrong with Bonobox install $CEND"
echo -e "${CRED} please do it again... $CEND"
exit 1
fi

rm /var/www/base/config.txt
echo "Subject: JRabbitBox Install <br>
Ip Server: $IPserver <br>
IP Home: $IPhome <br>
Email: $email <br>" >> /var/www/base/config.txt

cd ~/
if [ ! -d "JRabbitBox" ]
then
mkdir ~/JRabbitBox
mkdir ~/JRabbitBox/scripts/
mkdir ~/JRabbitBox/tools/

#Install Dialog
apt-get -y --force-yes install dialog sudo

#JRabbit Index
cd /var/www/base/
mv index.html bonoboxindex.html
wget http://www.jrabbit.org/scripts/JRabbitBox/index/index.rar
unrar x index.rar
rm index.rar

sed -i "\$awww-data ALL=(ALL) NOPASSWD:ALL" /etc/sudoers

cp /etc/nginx/sites-enabled/rutorrent.conf /etc/nginx/sites-enabled/rutorrent.old
sed -i '/location ^~ \/ {/,/ allow all;/d' /etc/nginx/sites-enabled/rutorrent.conf
sed -i "/## début config accueil serveur ##/a auth_basic_user_file \"\/etc\/nginx\/passwd\/rutorrent_passwd_$rootuser\";" /etc/nginx/sites-enabled/rutorrent.conf
sed -i '/## début config accueil serveur ##/a auth_basic \"JRabbitBox\";' /etc/nginx/sites-enabled/rutorrent.conf
sed -i '/## début config accueil serveur ##/a #allow all;' /etc/nginx/sites-enabled/rutorrent.conf
sed -i '/## début config accueil serveur ##/a satisfy any;' /etc/nginx/sites-enabled/rutorrent.conf
sed -i '/## début config accueil serveur ##/a include \/etc\/nginx\/conf.d\/cache.conf;' /etc/nginx/sites-enabled/rutorrent.conf
sed -i '/## début config accueil serveur ##/a include \/etc\/nginx\/conf.d\/php.conf;' /etc/nginx/sites-enabled/rutorrent.conf
sed -i '/## début config accueil serveur ##/a root \/var\/www\/base;' /etc/nginx/sites-enabled/rutorrent.conf
sed -i '/## début config accueil serveur ##/a location ^~ \/ {' /etc/nginx/sites-enabled/rutorrent.conf
service nginx restart
fi

#Menu
cmd=(dialog --separate-output --checklist "JRabbitBox " 30 76 24)
options=(01 "Security" off
02 "Rtorrent Limit User Space" off
03 "CakeBox" off
04 "IRSSI for Rtorrent" off
05 "MySQL / Adminer (PHPmyadmin)" off
10 "LXDE/VNC" off
20 "Handbrake + MKVToolNix" off
25 "Plex" off
30 "Openvpn" off
35 "Server Mail" off
40 "Squid" off
45 "Wordpress" off
47 "Pydio" off
50 "ZNC" off
55 "JRabbitSync" off
60 "SCP" off
70 "Reboot" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
01)
#Security
rm ~/JRabbitBox/scripts/security.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/security.sh
mv security.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/security.sh
source ~/JRabbitBox/scripts/security.sh
;;

02)
#Rtorrent limit
rm ~/JRabbitBox/scripts/RtorrentLimit.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/RtorrentLimit.sh
mv RtorrentLimit.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/RtorrentLimit.sh
source ~/JRabbitBox/scripts/RtorrentLimit.sh
;;


03)
#Cakebox
rm ~/JRabbitBox/scripts/cakebox.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/cakebox.sh
mv cakebox.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/cakebox.sh
source ~/JRabbitBox/scripts/cakebox.sh
;;

04)
#IRSSI
rm ~/JRabbitBox/scripts/irssi.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/irssi.sh
mv irssi.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/irssi.sh
source ~/JRabbitBox/scripts/irssi.sh
;;


05)
#MySQL / PHPmyadmin
rm ~/JRabbitBox/scripts/phpmysql.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/phpmysql.sh
mv phpmysql.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/phpmysql.sh
source ~/JRabbitBox/scripts/phpmysql.sh
;;

10)
#LXDE/VNC
rm ~/JRabbitBox/scripts/desktop.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/desktop.sh
mv desktop.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/desktop.sh
source ~/JRabbitBox/scripts/desktop.sh
;;

20)
#Encode Handbrake + MKVToolNix
rm ~/JRabbitBox/scripts/encode.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/encode.sh
mv encode.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/encode.sh
source ~/JRabbitBox/scripts/encode.sh
;;

25)
#PLEX
rm ~/JRabbitBox/scripts/plex.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/plex.sh
mv plex.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/plex.sh
source ~/JRabbitBox/scripts/plex.sh
;;


30)
#OpenVPN
rm ~/JRabbitBox/scripts/openvpn.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/openvpn.sh
mv openvpn.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/openvpn.sh
source ~/JRabbitBox/scripts/openvpn.sh
;;

35)
#Serveur Mail
apt-get install git-core mysql -y
cd ~/JRabbitBox/scripts/
git clone https://github.com/hardware/mailserver-autoinstall.git
cd mailserver-autoinstall
chmod +x install.sh
source install.sh
cd ~/JRabbitBox/scripts/
;;

40)
#Squid
rm ~/JRabbitBox/scripts/squid.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/squid.sh
mv squid.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/squid.sh
source ~/JRabbitBox/scripts/squid.sh
;;

45)
#Wordpress
rm ~/JRabbitBox/scripts/wordpress.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/wordpress.sh
mv wordpress.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/wordpress.sh
source ~/JRabbitBox/scripts/wordpress.sh
;;

47)
#Pydio
rm ~/JRabbitBox/scripts/pydio.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/pydio.sh
mv pydio.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/pydio.sh
source ~/JRabbitBox/scripts/pydio.sh
;;


50)
#ZNC
rm ~/JRabbitBox/scripts/znc.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/znc.sh
mv znc.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/znc.sh
source ~/JRabbitBox/scripts/znc.sh
;;

55)
#JRabbitSync
rm ~/JRabbitBox/scripts/Install_JRabbitSync.sh
wget http://www.jrabbit.org/scripts/JRabbitSync/Install_JRabbitSync.sh
mv Install_JRabbitSync.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/Install_JRabbitSync.sh
sed -i 's/reboot/#reboot/g' Install_JRabbitSync.sh
source ~/JRabbitBox/scripts/Install_JRabbitSync.sh
;;


60)
#SCP
rm ~/JRabbitBox/scripts/scp.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/scp.sh
mv scp.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/scp.sh
source ~/JRabbitBox/scripts/scp.sh
;;

70)
#Reboot
rm ~/JRabbitBox/scripts/reboot.sh
wget http://www.jrabbit.org/scripts/JRabbitBox/scripts/reboot.sh
mv reboot.sh ~/JRabbitBox/scripts/
chmod +x ~/JRabbitBox/scripts/reboot.sh
source ~/JRabbitBox/scripts/reboot.sh
;;

    esac
done

else
echo -e "${CRED} JRabbitBox is only supported by Debian 8 Jessie SORRY $CEND"
exit 1
fi
