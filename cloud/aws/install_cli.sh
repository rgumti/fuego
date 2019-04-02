#!/bin/bash
#install the awscli

#First we install pip
sudo yum install python-pip -y

#next upgrade python-pip
sudo pip install --upgrade pip

#install aws using the python package manager
sudo pip install awscli
