$name = "ubuntu"
$user = "abel"
$url = "https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-amd64-root.tar.gz"
$outfile = "ubuntu-focal-core-cloudimg-amd64-root.tar.gz"

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $outfile

LxRunOffline ui -n $name
LxRunOffline install -n $name -d $name -f $outfile
Remove-Item $outfile

wsl -d $name -- unminimize
wsl -d $name -- apt-get update
wsl -d $name -- apt-get upgrade 
wsl -d $name -- adduser $user
# TODO: passwd, ssh and gpg key

LxRunOffline.exe su -n $name -v 1000
