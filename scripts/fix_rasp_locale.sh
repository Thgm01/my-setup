#!/bin/bash

sudo apt update
sudo apt install locales -y
sudo sed -i 's/^# *\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8

echo "Fix locale error Complete. Disconnect and reconnect your SSH session."