function sync {
    sudo apt-get install -y $(cat pkglist.txt)
}
