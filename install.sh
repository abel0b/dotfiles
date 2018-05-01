#!/usr/bin/env bash

install() {
	./$1/install.sh
}

# pacman -S zsh zsh-syntax-highlighting atom i3-gaps

if [ ! -d ~/.oh-my-zsh ]; then
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

if [ -z $1 ]; then
	for dir in *; do
		if [ -d $dir ]; then
			install $dir
		fi
	done
else
	install $1
fi
