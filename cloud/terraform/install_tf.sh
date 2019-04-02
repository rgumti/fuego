#!/bin/bash
#install terraform

echo '=====CREATING DIRECTORIES====='
mkdir /tmp/terraform_INSTALLING
cd /tmp/terraform_INSTALLING

#download the installer
echo '=====DOWNLOADING INSTALLER====='
wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.10_linux_amd64.zip

#unzip the directory
echo '=====UNZIPPING====='
unzip terraform_0.11.10_linux_amd64.zip -d /tmp/terraform_INSTALLING/

#create a directory in /opt and move it in there
echo '=====MOVING TO /opt====='
mkdir /opt/terraform_files
mv /tmp/terraform_INSTALLING/terraform /opt/terraform_files/

#cleanup
echo 'CLEANUP'
rm -rf /tmp/terraform_INSTALLING



