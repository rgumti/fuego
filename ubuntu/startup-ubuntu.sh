#!/bin/bash
#WORK IN PROGRESS
#This script is used to install basic tools needed on fresh ubuntu image.

#update system
apt-get update -y
apt-get upgrade -y
apt-get update -y

#install basics
apt-get install vim wget rsync nfs-common mlocate net-tools ubuntu-restricted-extras facter -y

#install telegram:
wget -O- https://telegram.org/dl/desktop/linux | sudo tar xJ -C /opt/
ln -s /opt/Telegram/Telegram /usr/local/bin/telegram-desktop



