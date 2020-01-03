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
    ln -sf "/usr/share/zoneinfo/$region/$city" /etc/localtime
}

# Localization
function localization {
    sed -i "s/^#$locale/$locale/g" /etc/locale.gen
    locale-gen
    echo "LANG=$locale" > /etc/locale.conf
}

# Keyboard
function keyboard {
    echo "KEYMAP=$keymap" > /etc/vconsole.conf
}

# Network
function network {
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
    echo "$username ALL=(ALL) ALL" >> /etc/sudoers
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
    useradd -m -g users -G wheel -s $shell $username
}

# Softwares
function softwares {
    pacman --sync --needed --noconfirm - < $DOTFILES_PATH/system/archlinux/pkglist.txt

    if ! command -v yay && [[ -z ${CI:+x} ]]
    then
        tmpdir=$(cd ~ && mktemp -d -p .)
        git clone https://aur.archlinux.org/yay.git $tmpdir
        cd $tmpdir
        sudo makepkg -si --noconfirm
        rm -rf $tmpdir
    fi
}

time_zone
localization
keyboard
network
users
softwares
