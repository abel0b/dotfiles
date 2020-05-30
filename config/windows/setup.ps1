# configure wsl
wsl.exe --set-default-version 1
# TODO: wsl.exe --set-version DISTRIBUTION 2

# install scoop package manager
$ScoopFound = Get-Command "scoop" -errorAction SilentlyContinue 
if (-Not $ScoopFound) {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# add buckets
scoop bucket add extras

# install packages
function CheckInstall($pkg, $cmdname) {
    if (!$cmdname) {
        $cmdname = $pkg
    }
    $CommandFound = Get-Command -Name $cmdname -ErrorAction SilentlyContinue
    if (-Not $CommandFound) {
        scoop install $pkg
    }
}

CheckInstall "bat"
CheckInstall "cmake"
CheckInstall "dos2unix"
CheckInstall "firefox"
CheckInstall "fzf"
CheckInstall "gsudo"
CheckInstall "imagemagick" "magick"
CheckInstall "llvm" "lld"
CheckInstall "netcat" "nc"
CheckInstall "ninja"
CheckInstall "notepadplusplus" "notepad++"
CheckInstall "ssh-copy-id"
CheckInstall "tcc"
CheckInstall "vcxsrv"
CheckInstall "vim"
CheckInstall "vscode" "code"
