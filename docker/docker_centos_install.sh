#!/bin/bash
#Author: Raymond Gumti

#This Script will add the offical Docker Repository, download the latest version and perform the install.
curl -fsSL https://get.docker.com/ | sh

#Start Docker
sudo systemctl start docker

#Verify that it is running
sudo systemctl status docker

#Enable docker on boot
sudo systemctl enable docker

#add user to the docker group:
sudo usermod -aG docker $(whoami)
