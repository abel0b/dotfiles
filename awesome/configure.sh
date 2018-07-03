#!/usr/bin/env bash

echo "=== Configuring awesome ..."
mkdir -p ~/.config/awesome
ln -sf `pwd`/awesome/rc.lua ~/.config/awesome/rc.lua
ln -sf `pwd`/awesome/theme ~/.config/awesome
