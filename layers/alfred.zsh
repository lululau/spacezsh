#!/usr/bin/env zsh

spacezsh.alfred.browse-in-alfred() {
    osascript -e "tell app \"Alfred 3\" to browse \"$PWD/\""
    zle -K main
}

zle     -N    spacezsh.alfred.browse-in-alfred
bindkey -M SPACEZSH_KEYMAP "a" spacezsh.alfred.browse-in-alfred
