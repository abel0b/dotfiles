#!/usr/bin/env bash

CWD=$(pwd)
PACKAGE_MANAGER=pacman
PACKAGE_MANAGER_INSTALL="--sync --needed --noconfirm"
PACKAGE_MANAGER_REMOVE="--remove --noconfirm"

function forall() {
    for dir in $(ls dotfiles); do
        $1 $dir
    done
}

function link_one() {
    if [ -f "dotfiles/$1/link.txt" ]
    then
        while read line
        do
            target=$CWD/dotfiles/$(echo $line | cut -f 1 -d " ")
            linkname=$(echo $line | cut -f 2 -d " ")
            linkname="${linkname/#\~/$HOME}"

            mkdir --parent $(dirname $linkname)
            
            if [ -e $linkname ]
            then
                if [[ -L $linkname && $(readlink $linkname) == $target ]]
                then
                    :
                else
                    echo -e "\e[31m[error]\e[0m File already exists $linkname"
                fi
            else
                echo $target $linkname
                ln -s --no-target-directory $target $linkname
            fi
        done < "dotfiles/$1/link.txt"
        echo -e "\e[32m+\e[0m $1"
    fi
}

function unlink_one() {
    if [ -f "dotfiles/$1/link.txt" ]
    then
        while read line
        do
            bash -c "unlink $(echo $CWD/dotfiles/$line | cut -d " " -f 2) || true"
        done < "dotfiles/$1/link.txt"
        echo -e "\e[31m-\e[0m $1"
    fi
}

function link() {
    forall link_one
}

function unlink() {
    forall unlink_one
}

function setup() {
    username=abel
    shell=/usr/bin/bash
    hostname=abelpc
    local_domain=null
    region=Europe
    city=Paris
    locale=en_US.UTF-8
    keymap=fr

    # Time zone
    function time_zone {
        echo -e "\e[32m+\e[0m Time zone"
        ln -sf "/usr/share/zoneinfo/$region/$city" /etc/localtime
    }

    # Localization
    function localization {
        echo -e "\e[32m+\e[0m Localization"
        sed -i "s/^#$locale/$locale/g" /etc/locale.gen
        locale-gen
        echo "LANG=$locale" > /etc/locale.conf
    }

    # Keyboard
    function keyboard {
        echo -e "\e[32m+\e[0m Keyboard"
        echo "KEYMAP=$keymap" > /etc/vconsole.conf
    }

    # Network
    function network {
        echo -e "\e[32m+\e[0m Network"
        echo "$hostname" > /etc/hostname
        echo "# Static table lookup for hostnames." > /etc/hosts
        echo "# See hosts(5) for details." >> /etc/hosts
        echo "127.0.0.1 localhost" >> /etc/hosts
        echo "::1		    localhost" >> /etc/hosts
        echo "127.0.1.1	$hostname.$local_domain" >> /etc/hosts
    }

    # Users
    function users {
        echo "root ALL=(ALL) ALL" > /etc/sudoers
        echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
        useradd -m -g users -G wheel -s $shell $username || true
    }

    # Softwares
    function softwares {
        echo -e "\e[32m+\e[0m Softwares"
        pacman --sync --needed --noconfirm git
        pacman --sync --needed --noconfirm - < pkglist.txt
        apm install --packages-file dotfiles/atom/package-list.txt

        if [ -z ${CI+x} ]
        then
            tmpdir=$(su -c "cd ~ && mktemp -d -p ." $username)
            su -c "cd ~/$tmpdir && git clone https://aur.archlinux.org/package-query.git && cd package-query && makepkg -si --noconfirm" $username
            su -c "cd ~/$tmpdir && git clone https://aur.archlinux.org/yay.git && cd yaourt && makepkg -si --noconfirm" $username
            su -c "rm -r ~/$tmpdir" $username
            su -c "rm -rf ~/dotfiles && git clone https://gitlab.com/abeliam/dotfiles.git ~/dotfiles && cd ~/dotfiles && git remote add github https://github.com/abeliam/dotfiles.git && git submodule update && ./setup.sh link" $username
        fi
    }
    if [ -z "$1" ]
    then
        time_zone
        localization
        keyboard
        network
        users
        softwares
    else
        $1
    fi
}

command=${1:-setup}
if [[ "$command" =~ ^(link|unlink|setup)$ ]]
then
    $command $2
else
    echo "Usage: $0 [link|unlink|setup]"
fi
