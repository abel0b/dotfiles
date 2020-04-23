declare -a copy=(
    "keymap.cson" "~/.atom/keymap.cson"
    "config.cson" "~/.atom/config.cson"

)

function sync {
    cat package-list.txt | xargs apm install
}
