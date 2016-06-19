#!/bin/bash
#Author: warezcmpt
#This Script is a part of JRabbitBox
#More informations: http://www.jrabbit.org

cmd=(dialog --separate-output --checklist "JRabbitBox" 22 76 16)
options=(1 "Handbrake" on
         2 "MKVToolNix" on
	 3 "x265" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in

1)
# Installation Handbrake
echo ""
echo -e "${CRED}         Handbrake $CEND"
echo ""
	apt-get -y --force-yes install handbrake-gtk
;;

2)
# Installation MKVToolNix
echo ""
echo -e "${CRED}          MKVToolNix $CEND"
echo ""

	apt-get -y --force-yes install mkvtoolnix mkvtoolnix-gui
;;

3)
#x265
echo ""
echo -e "${CRED}          x265 $CEND"
echo ""
cd ~/
wget http://www.cmake.org/files/v3.1/cmake-3.1.0.tar.gz
tar zxfv cmake-3.1.0.tar.gz
rm cmake-3.1.0.tar.gz
cd cmake-3.1.0
./configure
make
sudo make install

cd ~/
hg clone https://bitbucket.org/multicoreware/x265
cd x265/build/linux

echo -e "${CRED}BIN_INSTALL_DIR => /usr/local/bin  $CEND"
read -p "Press c (configure) Then g (generate)"

./make-Makefiles.bash
make
;;
  esac
done

