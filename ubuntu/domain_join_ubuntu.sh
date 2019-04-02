#install  ntp

sudo apt-get install ntp
echo 'server 17.17.0.5
server 17.17.0.4' >> /etc/ntp.conf

#confirm ntp settings:
echo 'Refreshing ntp settings'
service ntp restart
ntpq -p

#update & install needed packages
echo 'Update, Upgrading, and installing necessary packages'
apt-get update -y  && apt-get upgrade -y && apt-get update -y && apt-get autoremove -y && apt-get autoclean -y && apt-get install screen vim gcc htop -y && sudo apt install -y ntp python-pip realmd sssd adcli krb5-user sssd-tools samba-common packagekit samba-common-bin samba-libs nfs-common

#Setting /etc/krb5.conf
echo '[libdefaults]
	default_realm = VIVA.LOCAL

# The following krb5.conf variables are only for MIT Kerberos.
	kdc_timesync = 1
	ccache_type = 4
	forwardable = true
	proxiable = true

# The following libdefaults parameters are only for Heimdal Kerberos.
	fcc-mit-ticketflags = true

[realms]
	VIVA.LOCAL = {
	}

[domain_realm]
 viva.local = VIVA.LOCAL
 .viva.local = VIVA.LOCAL' > /etc/krb5.conf

#update /etc/nsswitch.conf
echo'Updating /etc/nsswitch.conf to use dns'
echo ''
echo 'passwd:         compat sss
group:          compat sss
shadow:         compat sss
gshadow:        files

hosts:          files mdns4_minimal dns
networks:       files

protocols:      db files
services:       db files sss
ethers:         db files
rpc:            db files

netgroup:       nis sss
sudoers:        files sss' > /etc/nsswitch.conf

#Update /etc/avahi/avahi-daemon.conf to use include [server] domain-name=.alocal

#update pam
echo 'Updating PAM'

echo 'session   [default=1]                     pam_permit.so
session requisite                       pam_deny.so
session required                        pam_permit.so
session required        pam_unix.so 
session optional                        pam_sss.so 
session optional        pam_systemd.so 
session optional        pam_chksshpwd.so 
session required pam_mkhomedir.so skel=/etc/skel/ umask=0022' > /etc/pam.d/common-session

#refresh realmd service
echo 'Refresh realmd service'
service realmd restart

#discover the network
realm discover viva.local
echo 'Attempting to join viva.local domain'
realm join -U Administrator viva.local

#update sssd
echo 'Updating and Refreshing sssd'

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
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = false
fallback_homedir = /net/homes/%u
access_provider = ad' > /etc/sssd/sssd.conf	

service sssd restart


id fresco
