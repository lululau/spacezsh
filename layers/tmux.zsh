#!/usr/bin/env zsh

typeset -A SPACEZSH_TMUX_LAYOUT_MAPPINGS=(
    1 even-horizontal
    2 even-vertical
    3 main-horizontal
    4 main-vertical
    5 tiled
    t tiled
)

spacezsh.tmux.widget.selectl() {
    zle -K main
    local key=$KEYS[-1]
    local value=$SPACEZSH_TMUX_LAYOUT_MAPPINGS[$key]
    tmux selectl $value
    local ret=$?
    reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}
zle     -N    spacezsh.tmux.widget.selectl

for k (${(k)SPACEZSH_TMUX_LAYOUT_MAPPINGS}); do
    bindkey -M SPACEZSH_KEYMAP "t$k" spacezsh.tmux.widget.selectl
done

bindkey -M SPACEZSH_KEYMAP "t;" tmux-pane-words-prefix
bindkey -M SPACEZSH_KEYMAP ";" tmux-pane-words-prefix
