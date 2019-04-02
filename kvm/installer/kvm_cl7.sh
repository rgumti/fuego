#!/bin/bash

set -eu

#install required packages
echo '=====INSTALLING REQUIRED PACKAGES====='
yum groupinstall Virtualization "Virtualization Platform" "Virtualization Tools" -y
yum install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install virt-viewer -y
yum groupinstall "X Window System" -y
yum install tigervnc -y
echo ''
echo ''

#set tuned for virtualiztion
echo '=====Tuned for Virtulization====='
tuned-adm profile virtual-host
echo''

#start libvirtd service
echo '=====START/ENABLE LIBVIRTD SERVICE====='
systemctl enable libvirtd
systemctl start libvirtd
echo ''
#verify kvm installation
echo '=====VERIFYING KVM INSTALLATION====='
lsmod |grep -i kvm
echo ''
#configure bridged networking
echo '=====CONFIGURING BRIDGED NETWORKING====='
brctl show
echo ''
virsh net-list
echo ''

echo '=====Create br0====='
echo 'TYPE="Ethernet"
BOOTPROTO="none"
DEVICE="p2p1"
ONBOOT="yes"
BRIDGE=br0' > /etc/sysconfig/network-scripts/ifcfg-p2p1
cat /etc/sysconfig/network-scripts/ifcfg-p2p1
echo ''
echo 'DEVICE="br0"
# I am getting ip from DHCP server #
BOOTPROTO="dhcp"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
ONBOOT="yes"
TYPE="Bridge"
DELAY="0"' >> /etc/sysconfig/network-scripts/ifcfg-br0

cat /etc/sysconfig/network-scripts/ifcfg-br0

echo ''
echo '=====RESTART NETWORKING====='
systemctl restart NetworkManager
brctl show

echo ''
#set selinux to permissive mode
echo '======SETTING SELINUX TO PERMISSIVE====='
setenforce 0
echo ''


#install kimchi/wok
echo '=====INSTALLING KIMCHI/WOK====='
cd /tmp
wget https://github.com/kimchi-project/kimchi/releases/download/2.5.0/wok-2.5.0-0.el7.centos.noarch.rpm
wget https://github.com/kimchi-project/kimchi/releases/download/2.5.0/kimchi-2.5.0-0.el7.centos.noarch.rpm
yum install -y wok-2.5.0-0.el7.centos.noarch.rpm 
yum install -y kimchi-2.5.0-0.el7.centos.noarch.rpm
systemctl start wokd 
systemctl enable wokd

#edit wok.conf to allow proxy
echo '=====UPDATING WOK.CONF====='
echo '#
# Configuration file for Wok Web Server
#
[server]
# Start an SSL-enabled server on the given port
proxy_port = 8001

[logging]

[authentication]' > /etc/wok/wok.conf
cat /etc/wok/wok.conf
echo ''

#edit kimichi storage pool
echo '=====UPDATING KIMICHI STORAGE POOL====='
echo ' #
# Configuration file for Kimchi Templates
#

[main]

[memory]

[storage]

[[disk.0]]
pool = images

[graphics]

[processor]' > /etc/kimichi/template.conf
cat /etc/kimichi/template.conf
echo ''
#restart wokd
echo '=====STARTING WOK W/KIMCHI PLUGIN====='
systemctl restart wokd
echo ''
echo 'Navigate to $HOSTNAME:8001'


