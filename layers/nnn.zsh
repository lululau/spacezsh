#!/usr/bin/env zsh

function spacezsh.nnn.n() {
    nnn -i -c 1 "$@"

    if [ -f $NNN_TMPFILE ]; then
      . $NNN_TMPFILE
      rm -f $NNN_TMPFILE
    fi
}

spacezsh.nnn.widget() {
    zle -K main
    setopt localoptions pipefail 2> /dev/null
    spacezsh.nnn.n <>/dev/tty
    zle redisplay
    local ret=$?
    zle reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle     -N    spacezsh.nnn.widget

bindkey -M SPACEZSH_KEYMAP "n" spacezsh.nnn.widget


if [[ -z "$SPACEZSH_NNN_EXT_MAPPINGS" ]]; then
  typeset -A SPACEZSH_NNN_EXT_MAPPINGS=()
fi

for k (${(k)SPACEZSH_NNN_EXT_MAPPINGS}); do
    bindkey "$k" "$SPACEZSH_NNN_EXT_MAPPINGS[$k]"
done
