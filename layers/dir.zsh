#!/usr/bin/env zsh

if [[ -z "$SPACEZSH_DIR_MAPPINGS" ]]; then
  typeset -A SPACEZSH_DIR_MAPPINGS=()
fi

spacezsh.dir.widget() {
    local value=$SPACEZSH_DIR_MAPPINGS[${KEYS#d}]
    if [[ "$value" =~ '^=> ' ]]; then
        eval ${value#=> }
    elif [[ "$value" = '-' ]]; then
        cd "$OLDPWD"
    else
        cd "$value"
    fi
    zle -K main
    local ret=$?
    reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}

spacezsh.dir.tmux-pane.widget() {
  cd "$(tmux display-message -p "#{pane_current_path}")"
  zle -K main
  local ret=$?
  reset-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  omz_termsupport_precmd
  return $ret
}


zle     -N   spacezsh.dir.widget
zle     -N   spacezsh.dir.tmux-pane.widget

for k (${(k)SPACEZSH_DIR_MAPPINGS}); do
    if [[ "$k" =~ '^[a-zA-Z0-9/]+$' ]]; then
        bindkey -M SPACEZSH_KEYMAP "d$k" spacezsh.dir.widget
    else
        bindkey "$k" spacezsh.dir.widget
    fi
done

bindkey $'\030@s\015' spacezsh.dir.tmux-pane.widget
