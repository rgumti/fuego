#!/bin/bash
#Authored by fresco

#install the necessarry packages:
yum update -y && yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python ntp nfs-utils autofs ncdu iftop telnet -y

#disable firewall, selinux & cloud-init
systemctl stop firewalld
systemctl disable firewalld
systemctl mask --now firewalld

echo '
SELINUX=disabled
SELINUXTYPE=targeted
' > /etc/selinux/config 

touch /etc/cloud/cloud-init.disabled

#add mounts:
mkdir /net
mkdir /evo

echo '####Synology Mounts ####
fefe:/volume2/net      /net   nfs   rsize=8192,wsize=8192,timeo=14,intr
fefe:/volume1/evo_ssd  /evo   nfs   rsize=8192,wsize=8192,timeo=14,intr' >> /etc/fstab

mount -av

df -h /net
df -h /evo

#update ntp

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

#updated Samba Config:
echo '====================
      =Configuring Samba =
      ===================='

echo '
[global]
        workgroup = VIVA
        security = ads
        realm= VIVA.LOCAL
        kerberos method = secrets and keytab
        client signing = yes
        client use spnego = yes
'

service ntpd restart

service realmd restart

#join the viva.local domain
echo '=================
      =Joining Domain =
      ================='
net ads join -S VIVA-DOM -U Administrator%PASSWORD


#update krb5.conf
echo '=======================
      =Configuring Kerberos =
      =======================
      '
echo 'includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = VIVA.LOCAL
 dns_lookup_realm = true
 dns_lookup_kdc = true
 ticket_lifetime = 24h
 renew_lifetime = 7d
 rdns = false
 forwardable = yes

[domain_realm]
 viva.local = VIVA.LOCAL
 .viva.local = VIVA.LOCAL' > /etc/krb5.conf

#update nswitch.conf
echo 'passwd:     files sss
shadow:     files sss
group:      files sss

hosts:      files dns myhostname

bootparams: nisplus [NOTFOUND=return] files

ethers:     files
netmasks:   files
networks:   files
protocols:  files
rpc:        files
services:   files sss

netgroup:   nisplus sss

publickey:  nisplus

automount:  files
aliases:    files nisplus
' > /etc/nsswitch.conf

#update sssd
echo '===================
      =Configuring SSSD =
      ==================='
echo '[sssd]
domains = viva.local
config_file_version = 2
services = nss, pam

[domain/viva.local]
ad_domain = viva.local
krb5_realm = VIVA.LOCAL
realmd_tags = manages-system joined-with-adcli 
cache_credentials = True
id_provider = ad
access_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = false
fallback_homedir = /net/homes/%u
access_provider = ad' > /etc/sssd/sssd.conf	

echo 'Restarting sssd'
systemctl restart sssd
systemctl daemon-reload



#check id
id fresco |grep -i Lefferts

#Puppet installation
echo '===================
      =Installing Puppet=
      ==================='
rpm -Uvh https://yum.puppetlabs.com/puppet6/puppet6-release-el-7.noarch.rpm
yum update -y && yum install -y puppet-agent

echo "
[main]
certname = $HOSTNAME.viva.local
server = puppet.viva.local
environment = production
runinterval = 900
" > /etc/puppetlabs/puppet/puppet.conf

echo '===================
      = Enabling Puppet =
      ==================='

/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true


echo '================================
      = Setup Complete rebooting now =
      ================================'
reboot now
