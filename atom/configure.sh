#!/usr/bin/env bash

echo "=== Configuring atom ..."
ln -sf `pwd`/atom/keymap.cson ~/.atom/keymap.cson
ln -sf `pwd`/atom/config.cson ~/.atom/config.cson
