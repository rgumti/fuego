#!/bin/bash
#This script is used to install basic tools needed on fresh cl7 image.
yum update -y
yum upgrade -y
yum update -y

yum install vim wget rsync nfs-common nfs-utils mlocate net-tools  -y

wget dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm

rpm -ihv epel-release-7-11.noarch.rpm

yum install htop facter git -y

#Configure mounts
#mkdir /nfs
#mkdir /nfs/plex
#mkdir /nfs/files
#mkdir /nfs/ds1
#mkdir /nfs/install
#mkdir /nfs/backup

#chmod 777 -R /nfs


#mount 8.8.8.4:/nfs/files/scripts /mnt

#cat /mnt/fstab >> /etc/fstab

#reboot now

echo 'Startup installatins completed'
