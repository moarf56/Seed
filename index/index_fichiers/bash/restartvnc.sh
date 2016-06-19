#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

if [ -f "/var/www/rutorrent/histo.log" ] ; then
	#Root User
	roottest=$(sed '2q;d' /var/www/rutorrent/histo.log)
	rootuser="${roottest%%:*}"
elif [ -f "/var/www/rutorrent/histo_ess.log" ] ; then
	#Root User
	roottest=$(sed '2q;d' /var/www/rutorrent/histo_ess.log)
	rootuser="${roottest%%:*}"
else
echo -e "${CRED} OUPS something went wrong with Bonobox install $CEND"
echo -e "${CRED} please do it again... $CEND"
exit 1
fi

sudo -u $rootuser tightvncserver -kill :1
sudo -u $rootuser tightvncserver -geometry 1280x720 :1
