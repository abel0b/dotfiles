declare -a copy=(
    "ignore" "$HOME/.config/git/ignore"
    "config" "$HOME/.config/git/config"
)

function sync {
    git clone https://github.com/ingydotnet/git-subrepo.git $HOME/.local/src/git-subrepo
}
