#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

# MySQL / Adminer
cmd=(dialog --separate-output --checklist "JRabbitBox" 22 76 16)
options=(1 "MySQL" on
	 2 "Adminer (PHPmyadmin)" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in

1)
#MySQL
sudo apt-get -y --force-yes install mysql-server php5-mysql
;;

2)
#Adminer
sudo mkdir /usr/share/adminer
sudo wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
sudo ln -s /usr/share/adminer/latest.php /var/www/base/adminer.php

echo "Your Adminer page is available here: http://www.$IPserver/adminer.php <br>" >> /var/www/base/config.txt
;;

    esac
done

