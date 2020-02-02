#!/bin/bash

set -e

pacman -S --needed --noconfirm git
git clone https://github.com/abel0b/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh sync

