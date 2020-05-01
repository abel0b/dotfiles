# install scoop package manager
$ScoopFound = Get-Command "scoop" -errorAction SilentlyContinue 
if (-Not $ScoopFound) {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# add buckets
scoop bucket add extras

# install packages
# TODO: install if needed
scoop install docker
scoop install docker-compose
scoop install dos2unix
scoop install firefox
scoop install fzf
scoop install gsudo
scoop install llvm
scoop install netcat
scoop install notepadplusplus
scoop install obs-studio
scoop install ripgrep
scoop install ssh-copy-id
scoop install vcxsrv
scoop install vim
scoop install vscode
