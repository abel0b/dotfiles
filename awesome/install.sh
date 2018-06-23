#!/usr/bin/env bash

echo "=== Configuring awesome ..."
ln -sf `pwd`/awesome/rc.lua /etc/xdg/awesome/rc.lua
rm -rf /usr/share/awesome/themes/zenburn
ln -sf `pwd`/awesome/zenburn /usr/share/awesome/themes
