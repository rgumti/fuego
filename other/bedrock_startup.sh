#!/bin/bash
# Author: Ray Gumti & Javed Khan
# Description: Minecraft Bedrock Server Installer

BEDROCK_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-1.16.201.03.zip"
BEDROCK_PACKAGE="bedrock-server-1.16.201.03.zip"
PW1="JAVPASSWORD"
PW2="RAYPASSWORD"

#enable ssh password authentication:
sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/' /etc/ssh/sshd_config
systemctl restart sshd

# update
apt-get update -y
logger -t "$(basename "$0")" "app-get update complete"

# upgrade
apt-get upgrade -y
logger -t "$(basename "$0")" "app-get upgrade complete"

# install packages
apt-get install -y finger vim unzip net-tools libcurl4 openssl

# Disable cloud init
touch /etc/cloud/cloud-init.disabled
logger -t "$(basename "$0")" "cloud init disabled"

# set hostname
hostnamectl set-hostname bedrock
logger -t "$(basename "$0")" "hostname set"

# add admins (fresco & javed)
adduser --disabled-password --gecos "" javed
usermod -aG sudo javed
echo -e "$PW1\n$PW1\n" | passwd javed
logger -t "$(basename "$0")" "User javed added"

adduser --disabled-password --gecos "" fresco
usermod -aG sudo fresco
echo -e "$PW2\n$PW2\n" | passwd fresco
logger -t "$(basename "$0")" "User fresco added"

adduser --disabled-password --gecos "" minecraft
logger -t "$(basename "$0")" "User minecraft added"

# make workspace
mkdir /bedrock_server
chmod 777 /bedrock_server
cd /bedrock_server || logger -t "$(basename "$0")" "/bedrock_server folder not created"
logger -t "$(basename "$0")" "/bedrock_server folder created"

# download bedrock server from azure:
wget $BEDROCK_URL
logger -t "$(basename "$0")" "bedrock package downloaded"
# unzip server package
unzip $BEDROCK_PACKAGE -d /bedrock_server/
logger -t "$(basename "$0")" "bedrock package unziped to /bedrock_server"

#become minecraft user and start server
su - minecraft
cd /bedrock_server
logger -t "$(basename "$0")" "Starting Minecraft Bedrock Server"
