#!/usr/bin/env zsh

if [[ -z "$SPACEZSH_DIR_MAPPINGS" ]]; then
  typeset -A SPACEZSH_DIR_MAPPINGS=()
fi

spacezsh.dir.widget() {
    if [[ "${KEYS[1,2]}" = "$SPACEZSH_LEADER" ]]; then
        local key=$KEYS[-1]
    else
        local key=$KEYS
    fi
    local value=$SPACEZSH_DIR_MAPPINGS[$key]
    if [[ "$value" =~ '^=> ' ]]; then
        eval ${value#=> }
    else
        cd "$value"
    fi
    local ret=$?
    zle reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}

zle     -N   spacezsh.dir.widget

for k (${(k)SPACEZSH_DIR_MAPPINGS}); do
    if [[ "$k" =~ '^[a-zA-Z0-9/]+$' ]]; then
        bindkey "${SPACEZSH_LEADER}d$k" spacezsh.dir.widget
    else
        bindkey "$k" spacezsh.dir.widget
    fi
done

