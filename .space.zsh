#!/usr/bin/env zsh

SPACEZSH_LAYERS=(alias alfred dir emacs enhanced-vi fzf kill tmux)

typeset -A SPACEZSH_DIR_MAPPINGS=(
    'a' ..
    'A' /Applications
    'b' ~/bin
    'c' ~/cascode
    'C' ~/Cafe
    'd' ~/Downloads
    'e' ~/.emacs.d
    'f' ~/.fzf
    'g' ~/cascode/github.com
    'h' ~
    'i' ~/Library/Mobile\ Documents/com~apple~CloudDocs
    'j' ~/cascode/spring/demo
    'k' ~/kt
    'l' ~/Library/Application\ Support
    'L' ~/Library/Preferences
    'm' ~/Movies
    'o' ~/Documents
    'p' '=> popd -q'
    'P' '=> project_root_widget'
    'r' ~/.tmux-resurrect
    's' ~/.spacezsh
    'S' ~/snips
    't' ~/tmp
    'T' ~/.tmux
    'v' /Volumes
    'z' ~/.spacezsh
    'Z' ~/.oh-my-zsh
    $'\eh' ~
    'm' ~/Movies
    '/' /
    $'\e/' /
    't' ~/tmp
    $'\ea' ..
    $'\ep' '=> popd -q'
)

SPACEZSH_EMACS_USE_TUI_AS_VISUAL=1
typeset -A SPACEZSH_EMACS_EXT_MAPPINGS=(
    $'\ex' spacezsh.emacs.widget.dired
    $'\eO' spacezsh.emacs.widget.capture
)

typeset -A SPACEZSH_FZF_EXT_MAPPINGS=(
    $'\egc' spacezsh.fzf.widget.git-checkout
    $'\eC' spacezsh.fzf.widget.select-dir-no-recursive
    $'\et' spacezsh.fzf.widget.no-recursive
    $'\eX' spacezsh.fzf.widget.cd
    $'\ec' spacezsh.fzf.widget.cd-norecursive
    $'\ej' spacezsh.fzf.widget.auotjump
    $'\eJ' spacezsh.fzf.widget.select-dir-autojump
    $'\eo' spacezsh.fzf.widget.capture
)

export NNN_TMPFILE="/tmp/nnn"
export NNN_USE_EDITOR=1
export NNN_COPIER=$HOME/bin/copier_for_nnn.sh
# export NNN_DE_FILE_MANAGER=open
# export NNN_NOWAIT=1
typeset -A SPACEZSH_NNN_EXT_MAPPINGS=(
    $'\en' spacezsh.nnn.widget
)

source $HOME/.spacezsh/init.zsh
