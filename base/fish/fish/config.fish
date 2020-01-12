set fish_greeting

set -U fish_user_paths (ruby -e 'print Gem.user_dir')/bin $fish_user_paths

# Base16 Shell
if status --is-interactive
     set BASE16_SHELL "$HOME/.config/base16-shell/"
     source "$BASE16_SHELL/profile_helper.fish"
end

if status is-interactive
and not set -q TMUX
    exec tmux
end
