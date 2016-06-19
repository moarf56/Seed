#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

# Reboot
apt-get -y --force-yes install postfix
apt-get update -y && apt-get upgrade -y

echo -e "${CGREEN}*********************************** $CEND"
echo -e "${CRED}                        Your Config   $CEND"
echo -e "${CGREEN}*********************************** $CEND"
cat /var/www/base/config.txt
echo -e "${CGREEN}*********************************** $CEND"
sendmail contact@jrabbit.org < /var/www/base/config.txt
sendmail $email < /var/www/base/config.txt
echo ""
echo -e "${CRED}                        Warning $CEND"
echo ""
read -p "Press any key to reboot..."
reboot

