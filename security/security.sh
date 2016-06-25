#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

# Securisation serveur
cmd=(dialog --separate-output --checklist "JRabbitBox" 22 76 16)
options=(1 "User/Root Access" on
	 2 "IPtables" on
         3 "Backup-Manager" on
	 4 "Open Firewall port" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in

1)
apt-get -y --force-yes install sudo

#Nouveau MDP Root
echo -e "${CRED} New Root Password: $CEND"
passwd

#Add sudoer
sed -i "\$a$rootuser ALL=(ALL) NOPASSWD:ALL" /etc/sudoers

#Nouveau port SSH
echo -e " ${CYELLOW} New SSH port: $CEND "
read rootport
	re='^[0-9]+$'
	if ! [[ $rootport =~ $re ]] ; then
	echo "Only numbers !!!"
	echo -e "${CYELLOW} New SSH port: $CEND"
	read rootport
	fi

        sed -i "/Port 22/c Port $rootport" /etc/ssh/sshd_config
        sed -i "/PermitRootLogin yes/c PermitRootLogin no" /etc/ssh/sshd_config
        sed -i "/X11Forwarding yes/c X11Forwarding no" /etc/ssh/sshd_config
        sed -i "/UsePAM yes/a\AllowUsers $rootuser \n" /etc/ssh/sshd_config
        sed -i "/UsePAM yes/a\UseDNS no \n" /etc/ssh/sshd_config
	sed -i 's/Match/#Match/g' /etc/ssh/sshd_config
	sed -i 's/ChrootDirectory/#ChrootDirectory/g' /etc/ssh/sshd_config
        /etc/init.d/ssh restart

echo "SSH only with user: $rootuser <br>" >> /var/www/base/config.txt
echo "SSH port: $rootport <br>" >> /var/www/base/config.txt
;;

2)
echo "### BEGIN INIT INFO
# Provides: IPtables
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: IPtables
# Description: IPtables
### END INIT INFO
# Vider les tables actuelles
iptables -t filter -F
# Vider les regles personnelles
iptables -t filter -X
# Interdire toute connexion entrante et sortante
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP
# Ne pas casser les connexions etablies
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
# Autoriser loopback
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT
# ICMP (Ping)
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT
# SSH In
iptables -t filter -A INPUT -p tcp --dport $rootport -j ACCEPT
# SSH Out
iptables -t filter -A OUTPUT -p tcp --dport $rootport -j ACCEPT
# DNS In/Out
iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
# NTP Out
iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT
# HTTP + HTTPS Out
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
# HTTP + HTTPS In
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 8443 -j ACCEPT
# Mail SMTP:25
iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
# Mail POP3:110
iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
# Mail IMAP:143
iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT
# Mail POP3S:995
iptables -t filter -A INPUT -p tcp --dport 995 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 995 -j ACCEPT
# FTP Out
iptables -t filter -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
# FTP In
modprobe ip_conntrack_ftp # ligne facultative avec les serveurs OVH
iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT
iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Bonobox
iptables -t filter -A INPUT -p tcp --dport 5001 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 5001 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 45000 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 45000 -j ACCEPT" >> /etc/init.d/firewall

sed -i "1i\#!/bin/sh\n" /etc/init.d/firewall

chmod +x /etc/init.d/firewall
update-rc.d firewall defaults
service firewall restart

echo "Your firewall rules: /etc/init.d/firewall <br>" >> /var/www/base/config.txt
;;

3)
# Installation Backup-Manager
apt-get -y --force-yes install backup-manager

if [ -z "$rootuser" ]; then
echo -e "${CYELLOW} Root user: $CEND"
read rootuser
 sed -i "/export BM_REPOSITORY_USER="\"root"\"/c export BM_REPOSITORY_USER="\"$rootuser"\"" /etc/backup-manager.conf
 else
 sed -i "/export BM_REPOSITORY_USER="\"root"\"/c export BM_REPOSITORY_USER="\"$rootuser"\"" /etc/backup-manager.conf;
 fi

sed -i "/export BM_TARBALL_FILETYPE="\"tar.gz"\"/c export BM_TARBALL_FILETYPE="\"zip"\"" /etc/backup-manager.conf
sed -i "/export BM_UPLOAD_METHOD="\"scp"\"/c export BM_UPLOAD_METHOD="\"none"\"" /etc/backup-manager.conf
sed -i "/export BM_ARCHIVE_CHMOD="\"660"\"/c export BM_ARCHIVE_CHMOD="\"760"\"" /etc/backup-manager.conf
sed -i "/export BM_TARBALL_NAMEFORMAT="\"long"\"/c export BM_TARBALL_NAMEFORMAT="\"short"\"" /etc/backup-manager.conf

echo -e "${CYELLOW} How many days do you want to keep your Backup? $CEND"
read days
sed -i "/export BM_ARCHIVE_TTL="\"5"\"/c export BM_ARCHIVE_TTL="\"$days"\"" /etc/backup-manager.conf

sed -i "/export BM_BURNING_METHOD="\"CDRW"\"/c export BM_BURNING_METHOD="\"none"\"" /etc/backup-manager.conf

echo "#!/bin/sh
# cron script for backup-manager
test -x /usr/sbin/backup-manager || exit 0
/usr/sbin/backup-manager" >> /etc/cron.daily/backup-manager

cp $cwd/security/backup-manager-post /etc/backup-manager-post
sed -i "/\$dest = array('monitoring@test.com');/c \$dest = array('$email');" /etc/backup-manager-post

chmod +x /etc/cron.daily/backup-manager
chmod +x /etc/backup-manager-post

sed -i "/export BM_POST_BACKUP_COMMAND=""/c export BM_POST_BACKUP_COMMAND=\"\/etc\/backup-manager-post\"" /etc/backup-manager.conf
;;

4)
#Add port
echo -e "${CYELLOW} Do you want to open an other port in the Firewall? $CEND"
echo " (Yes = y | No = n): "
read addport
        while test $addport = "y"
        do
        echo -e "${CYELLOW} Port number: $CEND "
        read newport
                re='^[0-9]+$'
                if ! [[ $newport =~ $re ]] ; then
                echo "Only numbers !!!"
                echo -e "${CYELLOW} Port number: $CEND"
                read newport
                fi
        echo "#Manual Port
        iptables -t filter -A INPUT -p tcp --dport $newport -j ACCEPT
        iptables -t filter -A OUTPUT -p tcp --dport $newport -j ACCEPT" >> /etc/init.d/firewall

        echo -e "${CYELLOW} Do you want to open an other port in the Firewall? $CEND"
        read addport
        done

chmod +x /etc/init.d/firewall
update-rc.d firewall defaults
service firewall restart
;;

    esac
done
