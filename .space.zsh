#!/usr/bin/env zsh

SPACEZSH_LAYERS=(alias alfred dir emacs enhanced-vi fzf kill tmux issh nnn)

typeset -A SPACEZSH_DIR_MAPPINGS=(
    'a' ~/global-claude
    'A' /Applications
    'b' ~/blog
    'B' ~/bin
    'c' ~/.config
    'C' ~/cascode
    'd' ~/Downloads
    'D' ~/Documents
    'e' ~/.emacs.spacemacs.d
    'F' ~/Cafe
    'g' ~/cascode/github.com
    'h' ~
    'H' /home
    'i' ~/Library/Mobile\ Documents/com~apple~CloudDocs
    'j' ~/cascode/spring/demo
    'K' ~/kt
    'l' ~/Library/Application\ Support
    'L' ~/Library/Preferences
    'm' ~/Documents/materials
    'M' ~/Movies
    'k' ~/sd
    'p' '=> popd -q; chpwd'
    'P' '=> project_root_widget'
    $'\eR' '=> project_root_widget'
    'r' ~/.tmux-resurrect
    's' ~/Documents/scratches
    'S' ~/snips
    't' ~/tmp
    'T' ~/.Trash
    'v' /Volumes
    'z' ~/.spacezsh
    'Z' ~/.oh-my-zsh
    'v' /Volumes
    $'\eh' ~
    '/' /
    $'\e/' /
    't' ~/tmp
    $'\ea' ..
    $'\ep' '=> popd -q; chpwd'
    $'\e-' '-'
)

typeset -A SPACEZSH_EMACS_EXT_MAPPINGS=(
    # $'\ex' spacezsh.emacs.widget.dired
    $'\eO' spacezsh.emacs.widget.capture
)

typeset -A SPACEZSH_FZF_EXT_MAPPINGS=(
    $'\eg\ec' spacezsh.fzf.widget.git-checkout
    $'\eC' spacezsh.fzf.widget.select-dir-no-recursive
    $'\et' spacezsh.fzf.widget.cd
    $'\eX' spacezsh.fzf.widget.cd
    $'\eT' spacezsh.fzf.widget.no-recursive
    $'\ec' spacezsh.fzf.widget.cd-norecursive
    $'\ej' spacezsh.fzf.widget.auotjump
    $'\eJ' spacezsh.fzf.widget.select-dir-autojump
    $'\eo' spacezsh.fzf.widget.capture
)

SPACEZSH_BARE_SPACE_ENABLED=true
source $HOME/.spacezsh/init.zsh
