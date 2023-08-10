function sync {
    if ! command -v pwsh > /dev/null; then
        sudo curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -d | cut -d" " -f2)/packages-microsoft-prod.deb > $CACHE_PATH/packages-microsoft-prod.deb
        sudo dpkg -i $CACHE_PATH/packages-microsoft-prod.deb
        sudo apt-get update
    fi

    sudo apt-get update -y
    sudo apt-get -y --ignore-missing install $(cat pkglist.txt)
    #if ! command -v pwsh > /dev/null; then
    #    sudo apt-get -y install powershell
    #fi
}
