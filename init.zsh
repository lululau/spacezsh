#!/usr/bin/env zsh

SPACEZSH_HOME=$(cd $(dirname "$0"); pwd)

SPACEZSH_LEADER=$'\eq'

SPACE_KEYTIMEOUT=${SPACE_KEYTIMEOUT:-500}
KEYTIMEOUT=$SPACE_KEYTIMEOUT

for layer in "$SPACEZSH_LAYERS[@]"; do
    source "$SPACEZSH_HOME/layers/$layer.zsh"
done
