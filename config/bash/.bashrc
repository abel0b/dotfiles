# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case "$-" in
*i*)
	;;
*)
	return
	;;
esac

# Force la coloration du prompt (true/false)
COLOR_PROMPT="true"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL="ignoreboth"

# append to the history file, don't overwrite it
shopt -s "histappend"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE="1000"
HISTFILESIZE="2000"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s "checkwinsize"

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s "globstar"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x "/usr/bin/lesspipe" ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x "/usr/bin/dircolors" ]; then
	[ -r "${HOME}/.dircolors" ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
fi

# some more ls aliases
alias l='ls -CF'
alias ll='ls -l'
alias la='ls -A'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f "/usr/share/bash-completion/bash_completion" ]; then
		source "/usr/share/bash-completion/bash_completion"
	elif [ -f "/etc/bash_completion" ]; then
		source "/etc/bash_completion"
	fi
fi

export PS1='\h:\[\e[1;31m\]$(basename $PWD)\[\e[0m\]> '
export EDITOR=vim

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
