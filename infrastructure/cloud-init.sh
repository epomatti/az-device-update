#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo apt update
sudo apt upgrade -y

wget https://github.com/Azure/iot-hub-device-update/releases/download/1.0.2/Tutorial_Simulator.zip

wget https://packages.microsoft.com/config/ubuntu/18.04/multiarch/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt-get update
sudo apt-get install deviceupdate-agent -y
