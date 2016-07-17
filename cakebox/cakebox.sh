#!/bin/bash -i
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

if [ ! -d "/var/www/cakebox" ]
then
##composer
sudo apt-get install curl git
cd /tmp
curl -sS http://getcomposer.org/installer | php
mv /tmp/composer.phar /usr/bin/composer
chmod +x /usr/bin/composer

## nodejs
sudo apt-get install python g++ make
cd /tmp
#wget -N http://nodejs.org/dist/node-latest.tar.gz
#tar xzvf node-latest.tar.gz && cd node-v*
#./configure
#make
#make install
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

## bower
sudo npm install -g bower

cd /var/www/
git clone https://github.com/cakebox/cakebox.git
cd cakebox/
composer install

sed -i -e 's/"sha256": "https:\/\/crypto-js.googlecode.com\/svn\/tags\/3.1.2\/build\/rollups\/sha256.js",/"sha256": "https:\/\/storage.googleapis.com\/google-code-archive-downloads\/v2\/code.google.com\/crypto-js\/2.5.3-sha256.js",/g' bower.json

bower install --allow-root

if [ -z "$rootuser" ]; then
echo -e "${CYELLOW}What's your username?: $CEND"
read rootuser
fi

cp $cwd/cakebox/cakeboxuser /var/www/cakebox/config/$rootuser.php
sed -i "s/USER/$rootuser/g" /var/www/cakebox/config/$rootuser.php

#PHP Version
php=$(php -v | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')

cp $cwd/cakebox/cakebox.conf /etc/nginx/sites-enabled/cakebox.conf
sed -i "/location @site {/a fastcgi_pass unix:$PHPSOCK;" /etc/nginx/sites-enabled/cakebox.conf

cp /etc/nginx/sites-enabled/rutorrent.conf /etc/nginx/sites-enabled/rutorrent.old
sed -i '$ d' /etc/nginx/sites-enabled/rutorrent.conf
echo "location /cakebox/ {
        rewrite ^/cakebox(/.*)$ \$1 break;
        proxy_pass http://127.0.0.1:81;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_redirect off;
    }
    location /cakebox/$rootuser/ {
        alias /home/$rootuser/torrents/;
        add_header Content-Disposition \"attachment\";
        satisfy any;
        allow all;
	}
    }" >> /etc/nginx/sites-enabled/rutorrent.conf

service nginx restart && service $PHPNAME-fpm restart

cd /var/www/cakebox/
git pull origin master
bower update --allow-root

cd /var/www/rutorrent/plugins
git clone https://github.com/Cakebox/linkcakebox.git linkcakebox
chown -R www-data:www-data linkcakebox/

rm /var/www/rutorrent/plugins/linkcakebox/conf.php

echo "<?php
\$url = 'http://$IPserver/cakebox/';
\$dirpath = '/home/'.\$user.'/torrents/';
\$onglet = true;" >> /var/www/rutorrent/plugins/linkcakebox/conf.php

echo "#Cakebox
iptables -t filter -A INPUT -p tcp --dport 81 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 81 -j ACCEPT" >> /etc/init.d/firewall
fi

echo -e "${CYELLOW} Cakebox is installed for $rootuser $CEND"
echo -e "${CYELLOW} Do you want to install Cakebox for all users? (y/n) $CEND"
read yn
if [ $yn  == "y" ] ; then

cd /var/www/rutorrent/conf/users
for dir in *; do
echo "$dir"
cakeboxuser=$dir

if [ ! -f "/var/www/cakebox/config/$cakeboxuser.php" ]
then
cp $cwd/cakebox/cakeboxuser /var/www/cakebox/config/$dir.php
sed -i "s/USER/$dir/g" /var/www/cakebox/config/$dir.php

cp /etc/nginx/sites-enabled/rutorrent.conf /etc/nginx/sites-enabled/rutorrent.old
sed -i '$ d' /etc/nginx/sites-enabled/rutorrent.conf
echo "location /cakebox/$cakeboxuser/ {
	alias /home/$cakeboxuser/torrents/;
	add_header Content-Disposition \"attachment\";
	satisfy any;
	allow all;
	}
}" >> /etc/nginx/sites-enabled/rutorrent.conf
fi
done
fi
service nginx restart && service $PHPNAME-fpm restart
apt-get update -y && apt-get upgrade -y

echo "CakeBox: http://www.$IPserver/cakebox/ <br>" >> /var/www/base/config.txt
