#!/bin/bash -i
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

apt-get update -y && apt-get install openssl shellinabox -y

#Nouveau port
echo -e " ${CYELLOW} New shellinabox port: $CEND "
read port

sed -i "/SHELLINABOX_PORT=4200/c SHELLINABOX_PORT=$port" /etc/default/shellinabox

service shellinabox restart

#Iptables
until [ "$IPTyn" = "yes" ] || [ "$IPTyn" = "no" ]; do
echo -e  "${CYELLOW} Do you have an IPtables Firewall enable?: $CEND "
echo "ex: yes / no"
read IPTyn
done

if [ $IPTyn  == "yes" ] ; then

	echo -e  "${CYELLOW} Where's your firewall?: $CEND "
        echo "ex: /etc/init.d/firewall"
        read -e -i /etc/init.d/firewall IPTfile

	echo "#shellinabox
iptables -t filter -A INPUT -p tcp --dport $port -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport $port -j ACCEPT" >> $IPTfile
fi
