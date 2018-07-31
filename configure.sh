#!/usr/bin/env bash

configure() {
	./$1/configure.sh
}

if [ ! -d ~/.oh-my-zsh ]; then
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/configure.sh)"
fi

if [ -z $1 ]; then
	for dir in *; do
		if [ -d $dir ]; then
			if [ "$dir" != "bin" ]; then
				configure $dir
		
			fi
		fi
	done
else
	configure $1
fi
