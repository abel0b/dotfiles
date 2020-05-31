function sync {
    if ! command -v pwsh > /dev/null; then
        sudo wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -d | cut -d" " -f2)/packages-microsoft-prod.deb -O $CACHE_PATH/packages-microsoft-prod.deb
        sudo dpkg -i $CACHE_PATH/packages-microsoft-prod.deb
    fi

    sudo apt-get update -y
    sudo apt-get install -y --ignore-missing $(cat pkglist.txt)
    if ! command -v pwsh > /dev/null; then
        sudo apt-get install -y powershell
    fi
}
