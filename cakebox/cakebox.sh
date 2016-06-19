#!/bin/bash -i
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

if [ ! -d "/var/www/cakebox" ]
then
## nodejs
cd /tmp
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
source ~/.bashrc
nvm install v5.3.0

cd /var/www
git clone https://github.com/Cakebox/cakebox.git
cd cakebox
composer install
bower install --allow-root

if [ -z "$rootuser" ]; then
echo -e "${CYELLOW}What's your username?: $CEND"
read rootuser
fi

cp ~/JRabbitBox/cakebox/cakeboxuser /var/www/cakebox/config/
mv cakeboxuser $rootuser.php
sed -i "s/USER/$rootuser/g" /var/www/cakebox/config/$rootuser.php

echo "server {
    listen 81;
    server_name _;
    root /var/www/cakebox/public;
    index index.php;
    allow 127.0.0.1; # only the proxy
    deny all;
    charset utf-8;
    include /etc/nginx/conf.d/cache.conf;
    access_log /var/log/nginx/cakebox-access.log;
    error_log /var/log/nginx/cakebox-error.log;
    location = / {
        try_files @site @site;
    }
    location / {
        try_files \$uri \$uri/ @site;
    }
    location ~ \\.php$ {
        return 404;
    }
    location @site {
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
        fastcgi_param APPLICATION_ENV production;
        ## uncomment when running via https
        ## fastcgi_param HTTPS on;
    }
}" >> /etc/nginx/sites-enabled/cakebox.conf

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

service nginx restart

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
cp ~/JRabbitBox/cakebox/cakeboxuser /var/www/cakebox/config/
mv cakeboxuser $dir.php
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
service nginx restart

echo "CakeBox: http://www.$IPserver/cakebox/ <br>" >> /var/www/base/config.txt