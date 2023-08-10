declare -a copy=(
    "get=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
    "init.vim" "~/.config/nvim/init.vim"
    "coc-settings.json" "~/.config/nvim/coc-settings.json"
)

function sync {
    nvim -E -s +'PlugInstall --sync' +qa
}
