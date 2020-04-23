#!/usr/bin/env bash

set -e

if [[ -f "/etc/arch-release" ]]
then
    pacman -S --needed --noconfirm git
    host="arch"
elif [[ $(cat /etc/os-release) =~ "Ubuntu" ]]
then
    apt-get install git
    host="ubuntu"
else
    echo "Unable to determine os"
    exit 1
fi

git clone https://github.com/abel0b/dotfiles.git ~/dotfiles
cd ~/dotfiles
./dotman.sh sync $host
