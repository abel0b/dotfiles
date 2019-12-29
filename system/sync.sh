function setup() {
    username=abel
    shell=/usr/bin/bash
    hostname=abelpc
    local_domain=null
    region=Europe
    city=Paris
    locale=en_US.UTF-8
    keymap=fr
    
    set -e
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
        pacman --sync --needed --noconfirm - < system/pkglist.txt

        if [ -z ${CI+x} ]
        then
            tmpdir=$(su -c "cd ~ && mktemp -d -p ." $username)
            su -c "cd ~/$tmpdir && git clone https://aur.archlinux.org/package-query.git && cd package-query && makepkg -si --noconfirm" $username
            su -c "cd ~/$tmpdir && git clone https://aur.archlinux.org/yay.git && cd yaourt && makepkg -si --noconfirm" $username
            su -c "rm -r ~/$tmpdir" $username
            su -c "git clone https://github.com/abel0b/dotfiles.git ~/dotfiles && cd ~/dotfiles && git remote add gitlab https://gitlab.com/abeliam/dotfiles.git && ./setup.sh sync" $username
         fi                                                                     }

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

setup $1

