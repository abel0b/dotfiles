function sync {
    if [[ ! $EUID = 0 ]]; then
        echo "Please run as root"
        return
    fi

    username=abel
    shell=/usr/bin/bash
    hostname=minitel
    local_domain=null
    region=Europe
    city=Paris
    locale=en_US.UTF-8
    keymap=fr

    # Time zone
    ln -sf "/usr/share/zoneinfo/$region/$city" /etc/localtime

    # Localization
    sed -i "s/^#$locale/$locale/g" /etc/locale.gen
    locale-gen
    echo "LANG=$locale" > /etc/locale.conf

    # Keyboard
    echo "KEYMAP=$keymap" > /etc/vconsole.conf

    # Network
    echo "$hostname" > /etc/hostname
    echo "# Static table lookup for hostnames." > /etc/hosts
    echo "# See hosts(5) for details." >> /etc/hosts
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1		    localhost" >> /etc/hosts
    echo "127.0.1.1	$hostname.$local_domain" >> /etc/hosts

    # Users
    #echo "root ALL=(ALL) ALL" > /etc/sudoers
    #echo "$username ALL=(ALL) ALL" >> /etc/sudoers
    #echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
    #useradd -m -g users -G wheel -s $shell $username

    # Softwares
    pacman --sync --needed --noconfirm - < pkglist.txt

    if ! command -v yay && [[ -z ${CI:+x} ]]
    then
        tmpdir=$(cd ~ && mktemp -d)
        git clone https://aur.archlinux.org/yay.git $tmpdir
        cd $tmpdir
        makepkg -si --noconfirm
        rm -rf $tmpdir
    fi
}
