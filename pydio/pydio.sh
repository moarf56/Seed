#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

# Pydio
echo ""
echo -e "${CRED}         Pydio $CEND"
echo ""

file="/etc/init.d/mysql"
if [ -f "$file" ]
then
	echo "$file found."
else
	apt-get -y --force-yes install mysql-server php7.0-mysql php7.0 php7.0-fpm php7.0-gd php7.0-cli php7.0-mcrypt
fi

cd /tmp
wget -O pydio-core-6.2.2.tar.gz http://sourceforge.net/projects/ajaxplorer/files/pydio/stable-channel/6.2.2/pydio-core-6.2.2.tar.gz/download
tar zxvf pydio-core*.tar.gz
mv /tmp/pydio-core-6.2.2 /var/www/pydio
chown -R www-data:www-data /var/www/

#Nginx Conf
echo "location = /pydio/conf/       { deny all; }
location = /pydio/data/       { deny all; }
location = /pydio/robots.txt  { access_log off; log_not_found off; }
location = /pydio/favicon.ico { access_log off; log_not_found off; }
location ~ /pydio/\\.          { access_log off; log_not_found off; deny all; }
location ~ ~\$           { access_log off; log_not_found off; deny all; }" >> /etc/nginx/conf.d/pydio_drop

echo "location ~ \\.php {
    try_files \$uri =404;
    fastcgi_param  QUERY_STRING       \$query_string;
    fastcgi_param  REQUEST_METHOD     \$request_method;
    fastcgi_param  CONTENT_TYPE       \$content_type;
    fastcgi_param  CONTENT_LENGTH     \$content_length;
    fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
    fastcgi_param  SCRIPT_FILENAME    \$request_filename;
    fastcgi_param  REQUEST_URI        \$request_uri;
    fastcgi_param  DOCUMENT_URI       \$document_uri;
    fastcgi_param  DOCUMENT_ROOT      \$document_root;
    fastcgi_param  SERVER_PROTOCOL    \$server_protocol;
    fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
    fastcgi_param  SERVER_SOFTWARE    nginx;
    fastcgi_param  REMOTE_ADDR        \$remote_addr;
    fastcgi_param  REMOTE_PORT        \$remote_port;
    fastcgi_param  SERVER_ADDR        \$server_addr;
    fastcgi_param  SERVER_PORT        \$server_port;
    fastcgi_param  SERVER_NAME        \$server_name;
    fastcgi_pass unix:/var/run/php7.0-fpm.sock;
}" >> /etc/nginx/conf.d/pydio_php

echo "location ~* \\.(?:ico|css|js|gif|jpe?g|png)\$ {
    expires max;
    add_header Pragma public;
    add_header Cache-Control \"public, must-revalidate, proxy-revalidate\";
}" >> /etc/nginx/conf.d/pydio_cache

sed -i '$ d' /etc/nginx/sites-enabled/rutorrent.conf
echo "location /pydio {
	root /var/www;
	index index.php;
	access_log /var/log/nginx/pydio.access.log;
	error_log /var/log/nginx/pydio.error.log;
	include /etc/nginx/conf.d/pydio_drop;
	include /etc/nginx/conf.d/pydio_php;
	include /etc/nginx/conf.d/pydio_cache;
	satisfy any;
	allow all;
}
}" >> /etc/nginx/sites-enabled/rutorrent.conf

clear

echo -e "${CYELLOW} Pydio user: $CEND"
read pydiouser
echo -e "${CYELLOW} Pydio password: $CEND"
read pydiomdp
chmod +x ~/JRabbitBox/phpmysql/mysqldb.sh
echo -e "${CYELLOW} MySQL password: $CEND"
source $cwd/phpmysql/mysqldb.sh pydio $pydiouser $pydiomdp

sed -i "/post_max_size = 10M/c post_max_size = 20G" /etc/php/7.0/fpm/php.ini
sed -i "/upload_max_filesize = 10M/c upload_max_filesize = 20G" /etc/php/7.0/fpm/php.ini
sed -i "/max_file_uploads = 20/c max_file_uploads = 20000" /etc/php/7.0/fpm/php.ini
sed -i "/post_max_size = 10M/c post_max_size = 20G" /etc/php/7.0/fpm/php.ini
sed -i "/output_buffering = 4096/c output_buffering = off" /etc/php/7.0/fpm/php.ini

sed -i "/client_max_body_size 10M;/c client_max_body_size 20G;" /etc/nginx/sites-enabled/rutorrent.conf

service php7.0-fpm restart
service nginx restart
service mysql restart

echo "Pydio: 
http://$IPserver/pydio/ <br>" >> /var/www/base/config.txt

