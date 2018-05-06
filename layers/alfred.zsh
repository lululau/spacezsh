#!/usr/bin/env zsh

spacezsh.alfred.browse-in-alfred() {
    osascript -e "tell app \"Alfred 3\" to browse \"$PWD/\""
}
zle     -N    spacezsh.alfred.browse-in-alfred
bindkey "${SPACEZSH_LEADER}a" spacezsh.alfred.browse-in-alfred
