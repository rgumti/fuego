#!/bin/bash
#Authored by fresco
#Version 0.1.1

realName=$(host `hostname -i`  | cut -d' ' -f 5 |sed 's/.$//')
ipAddress=(`hostname -i`)

echo '
=====================================
= Setting Hostname According to DNS =
=====================================
'
hostnamectl set-hostname $realName

echo "Hostname set to $realName with IP: $ipAddress"

echo '

=============================
= Starting Package Install  =
=============================
'
#install the necessarry packages:
yum update -y && yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python ntp nfs-utils autofs pam_krb5 telnet -y

#disable firewall & selinux
systemctl stop firewalld
systemctl disable firewalld
systemctl mask --now firewalld

echo '
SELINUX=disabled
SELINUXTYPE=targeted
' > /etc/selinux/config



#add mounts:
echo '

=================
= Adding Mounts =
=================
'

mkdir /net
mkdir /evo

echo '####Synology Mounts ####
fefe:/volume2/net      /net   nfs   rsize=8192,wsize=8192,timeo=14,intr
fefe:/volume1/evo_ssd  /evo   nfs   rsize=8192,wsize=8192,timeo=14,intr' >> /etc/fstab

mount -av

df -h /net
df -h /evo


#update ntp
echo '

==============================
= Configuring NTP & Timezone =
==============================
'

timedatectl set-timezone America/New_York

echo 'driftfile /var/lib/ntp/drift

restrict default nomodify notrap nopeer noquery

restrict 127.0.0.1
restrict ::1

includefile /etc/ntp/crypto/pw

keys /etc/ntp/keys

disable monitor
server 17.17.0.5
server 17.17.0.4
' > /etc/ntp.conf

service ntpd restart

#domain Join
echo '

==========================
= Attempting Domain Join =
=========================='


echo -n '<PASSWORD>' | adcli join viva.local -U Administrator --stdin-password


realm list





#update krb5.conf

echo '

=====================
= Editing krb5.conf =
=====================
'

echo '[logging]
 default = FILE:/var/log/krb5libs.log

[libdefaults]
 default_realm = VIVA.LOCAL
 dns_lookup_realm = true
 dns_lookup_kdc = true
 ticket_lifetime = 24h
 renew_lifetime = 7d
 rdns = false
 forwardable = yes

 VIVA.LOCAL = {
 }

[domain_realm]
 viva.local = VIVA.LOCAL
 .viva.local = VIVA.LOCAL' > /etc/krb5.conf

#update nswitch.conf
echo '
=====================
= Updating nsSWITCH =
=====================
'
authconfig --enablesssd --enablesssdauth --enablemkhomedir --update


#update sssd
echo '

===================
=  Updating SSSD  =
===================
'

echo '
[sssd]
services = nss, pam, ssh, autofs
config_file_version = 2
domains = viva.local

[domain/VIVA.LOCAL]
ad_domain = viva.local
krb5_realm = VIVA.LOCAL
id_provider = ad
default_shell = /bin/bash
use_fully_qualified_names = false
fallback_homedir = /net/homes/%u' > /etc/sssd/sssd.conf

chmod 600 /etc/sssd/sssd.conf
chown root:root /etc/sssd/sssd.conf

echo 'Restarting sssd'
systemctl restart sssd
systemctl daemon-reload

systemctl status sssd.service




















