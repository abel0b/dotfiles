#!/usr/bin/env bash

echo "=== Configuring i3status ..."

mkdir -p ~/.config/i3status
ln -sf `pwd`/i3status/config ~/.config/i3status
