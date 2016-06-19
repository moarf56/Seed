#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org
port="$1"

echo "Port $1 opened <br>" >> ../config.txt

echo "iptables -t filter -A INPUT -p tcp --dport $1 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport $1 -j ACCEPT" >> /etc/init.d/firewall
service firewall restart
