#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

echo ""
echo -e "${CRED}         SCP $CEND"
echo ""

        read -p "Distant server user: " scpuser
        read -p "Distant SSH port: " scpport
        read -p "Distant server IP" scpip
	read -p "Distant folder to download:" scpfolder
	read -p "Local folder:" scpfolderlocal

scp -P $scpport -r $scpuser\@$scpip:$scpfolder $scpfolderlocal

echo -e "${CYELLOW} Download an other folder (y/n): $CEND "
read scp
while test $scp = "y"
do
read -p "Distant folder to download:" scpfolder
read -p "Local folder:" scpfolderlocal
scp -P $scpport -r $scpuser\@$scpip:$scpfolder $scpfolderlocal
echo -e "${CYELLOW} Download an other folder (y/n): $CEND"
read scp
done
