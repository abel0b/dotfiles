#!/bin/bash

set -e

git clone https://github.com/abel0b/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh sync
./setup.sh sync system

