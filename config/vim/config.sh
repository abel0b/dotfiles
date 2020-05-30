declare -a copy=(
    "get=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" "~/.vim/autoload/plug.vim"
    "../neovim/init.vim" "~/.vimrc"
)

function sync {
    vim +'PlugInstall --sync' +qa
}
