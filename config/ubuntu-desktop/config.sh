function sync {
    sudo apt-get update -y
    sudo apt-get install -y --ignore-missing $(cat pkglist.txt)
}
