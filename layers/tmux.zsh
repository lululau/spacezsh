#!/usr/bin/env zsh

typeset -A SPACEZSH_TMUX_LAYOUT_MAPPINGS=(
    1 even-horizontal
    2 even-vertical
    3 main-horizontal
    4 main-vertical
    5 tiled
)

spacezsh.tmux.widget.selectl() {
    local key=$KEYS[-1]
    local value=$SPACEZSH_TMUX_LAYOUT_MAPPINGS[$key]
    tmux selectl $value
    local ret=$?
    zle reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}
zle     -N    spacezsh.tmux.widget.selectl

for k (${(k)SPACEZSH_TMUX_LAYOUT_MAPPINGS}); do
    bindkey "${SPACEZSH_LEADER}t$k" spacezsh.tmux.widget.selectl
done

bindkey -s "${SPACEZSH_LEADER}tk" 'tmux kill-server\n'
