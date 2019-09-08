#!/usr/bin/env zsh

SPACEZSH_HOME=$(cd $(dirname "$0"); pwd)

SPACEZSH_LEADER=$'\eq'
# SPACEZSH_LEADER='^X@s,'

SPACEZSH_KEYTIMEOUT=${SPACEZSH_KEYTIMEOUT:-500}
KEYTIMEOUT=$SPACEZSH_KEYTIMEOUT

function reset-prompt() {
  if [ -n "$STARSHIP_SHELL" ]; then
    starship_precmd
  fi
  zle reset-prompt
}

function SPACEZSH_WIDGET_FALLBACK() {
    if [ "$KEYS" = ' ' ]; then
        zle self-insert
    else
        zle -K main
    fi
}
zle -N SPACEZSH_WIDGET_FALLBACK
bindkey -N SPACEZSH_KEYMAP_FALLBACK
bindkey -M SPACEZSH_KEYMAP_FALLBACK -R '\x00-\xff' SPACEZSH_WIDGET_FALLBACK

bindkey -N SPACEZSH_KEYMAP SPACEZSH_KEYMAP_FALLBACK


function SPACEZSH_WIDGET() {
    zle -K SPACEZSH_KEYMAP
}

zle -N SPACEZSH_WIDGET
bindkey "$SPACEZSH_LEADER" SPACEZSH_WIDGET

function SPACEZSH_SPACE_DISPATCH_WIDGET() {
    if [[ "$LBUFFER" =~ '^ *$' || "${BUFFER[$CURSOR]}" == ' ' ]]; then
        zle -K SPACEZSH_KEYMAP
    else
        zle self-insert
    fi
}
zle -N SPACEZSH_SPACE_DISPATCH_WIDGET

if [ -n "$SPACEZSH_BARE_SPACE_ENABLED" ]; then
    bindkey ' ' SPACEZSH_SPACE_DISPATCH_WIDGET
fi

for layer in "$SPACEZSH_LAYERS[@]"; do
    source "$SPACEZSH_HOME/layers/$layer.zsh"
done

source "$SPACEZSH_HOME/help.zsh"
