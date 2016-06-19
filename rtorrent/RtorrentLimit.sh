#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

echo -e "${CYELLOW}Username to limit: $CEND"
read rtorrentuser

echo -e "${CYELLOW}$rtorrentuser size in GO: $CEND"
read size
echo -e "${CRED}Warning: This step takes time... $CEND"
dd if=/dev/zero of=/home/$rtorrentuser.img bs=1127428915 count=$size
mkfs.ext4 /home/$rtorrentuser.img
mount -o loop /home/$rtorrentuser.img /home/$rtorrentuser/torrents/
echo "/home/$rtorrentuser.img    /home/$rtorrentuser/torrents/    ext4    loop    0    2" >> /etc/fstab

chmod -R 775 /home/$rtorrentuser/torrents
chown -R $rtorrentuser:$rtorrentuser /home/$rtorrentuser/torrents

echo -e "${CGREEN}Done! $CEND"

