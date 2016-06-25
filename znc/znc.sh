#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

echo ""
echo -e "${CRED}         ZNC $CEND"
echo ""
apt-get -y --force-yes install znc sudo
useradd --create-home -d /var/lib/znc --system --shell /sbin/nologin --comment "Account to run ZNC daemon" --user-group znc
sudo -u znc /usr/bin/znc --datadir=/var/lib/znc --makeconf

echo -e "${CYELLOW} Enter ZNC port you just pick: $CEND "
read zncport
re='^[0-9]+$'
if ! [[ $zncport =~ $re ]] ; then
echo "Only Numbers!!!"
echo -e "${CYELLOW} Enter ZNC port you just pick: $CEND"
read zncport
fi

echo "#ZNC
iptables -t filter -A INPUT -p tcp --dport $zncport -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport $zncport -j ACCEPT" >> /etc/init.d/firewall

rm /etc/init.d/znc
cp $cwd/znc/znc /etc/init.d/znc
chmod 755 /etc/init.d/znc
chmod +x /etc/init.d/znc

echo "[Unit]
Description=ZNC, an advanced IRC bouncer
After=network.target
[Service]
ExecStart=/usr/bin/znc -f --datadir=/var/lib/znc
User=znc
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/znc.service

systemctl enable znc
service znc start

echo "ZNC: http://www.$IPserver:$zncport <br>" >> /var/www/base/config.txt
