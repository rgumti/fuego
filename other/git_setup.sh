#!/bin/bash

echo 'This script will install and configure git'
echo ''
echo ''
echo 'Installing Git'
yum install git -y
echo ''
echo 'Making git directory'
mkdir git
cd git
echo 'Cloning the rgumti automation git repo'

git clone https://github.com/rgumti/automation.git

echo ''

echo 'Configuring Repo'

echo 'Setting user.email'
git config --global user.email  <USER@EMAIL.COM>

echo ''
echo 'Setting user.name'
git config --global user.name <USER NAME>

echo ''
echo 'Checking status'
git status

echo 'all done'

