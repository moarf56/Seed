#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org
echo ""
echo -e "${CRED}         Wordpress $CEND"
echo ""
file="/etc/init.d/mysql"
if [ -f "$file" ]
then
        echo "MySQL found."
else
        apt-get -y --force-yes install mysql-server $PHPNAME-mysql
fi

cd /var/www/
wget http://wordpress.org/latest.tar.gz
tar zxvf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
chown -R www-data:www-data /var/www/wordpress
rm latest.tar.gz

echo -e "${CYELLOW} Wordpress User: $CEND"
read wpuser
echo -e "${CYELLOW}Password: $CEND"
read wpmdp
chmod +x ~/JRabbitBox/phpmysql/mysqldb.sh
echo -e "${CYELLOW}MySql Password:  $CEND"
source $cwd/phpmysql/mysqldb.sh wordpress $wpuser $wpmdp
sed -i "/database_name_here/c define('DB_NAME', 'wordpress');" /var/www/wordpress/wp-config.php
sed -i "/username_here/c define('DB_USER', '$wpuser');" /var/www/wordpress/wp-config.php
sed -i "/password_here/c define('DB_PASSWORD', '$wpmdp');" /var/www/wordpress/wp-config.php

echo -e "${CYELLOW} Do you have a domain name? (y/n) $CEND"
read yn
if [ $yn  == "y" ]
then
	echo -e "${CYELLOW} Domain extention? (ex: com/org/net/...) $CEND"
	read ext
	echo -e "${CYELLOW} Domain name? (ex: mydomain) $CEND"
	read domain
cd /etc/nginx/sites-enabled/
	echo "server {
        listen 80;
        listen 443 ssl;
        server_name $domain.$ext www.$domain.$ext;
        index index.html index.php;
        charset utf-8;
        client_max_body_size 10M;
        ssl_certificate /etc/nginx/ssl/server.crt;
        ssl_certificate_key /etc/nginx/ssl/server.key;
        include /etc/nginx/conf.d/ciphers.conf;
        access_log /var/log/nginx/rutorrent-access.log combined;
        error_log /var/log/nginx/rutorrent-error.log error;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html { root /usr/share/nginx/html; }
        location = /favicon.ico {
                access_log off;
                log_not_found off;
        }
        location ^~ / {
	try_files \$uri \$uri/ /index.php?\$args;
            root /var/www/wordpress;
            include /etc/nginx/conf.d/php.conf;
            include /etc/nginx/conf.d/cache.conf;
        }
}" >> /etc/nginx/sites-enabled/wordpress.conf

echo "Wordpress: http://www.$domain.$ext/ <br>" >> /var/www/base/config.txt

else
	cp /etc/nginx/sites-enabled/rutorrent.conf /etc/nginx/sites-enabled/rutorrent.old
	sed -i '$ d' /etc/nginx/sites-enabled/rutorrent.conf
	echo "location ^~ /wordpress {
	root /var/www;
	try_files \$uri \$uri/ /index.php?\$args;
	include /etc/nginx/conf.d/php.conf;
	include /etc/nginx/conf.d/cache.conf;
	satisfy any;
	allow all;
	}
	}" >> /etc/nginx/sites-enabled/rutorrent.conf

echo "Wordpress: http://www.$IPserver/wordpress/ <br>" >> /var/www/base/config.txt
fi
service nginx restart
service mysql restart
