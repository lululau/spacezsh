#!/usr/bin/env zsh

spacezsh.kill.fzfcmd_complete() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
      echo "fzf-tmux -d${FZF_HEIGHT}" || echo "fzf"
}

spacezsh.kill.widget() {
  local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
  fzf="$(spacezsh.kill.fzfcmd_complete)"
  matches=$(ps -ef | sed 1d | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} --min-height 15 --reverse $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS" ${=fzf} -m -e | awk '{print $2}' | tr '\n' ' ')
  if [ -n "$matches" ]; then
    if [ "$KEYS[-1]" = k ]; then
        RBUFFER="lsof -Pnp $matches"
    elif [ -n "$LBUFFER" ]; then
        LBUFFER="$LBUFFER$matches"
    else
        LBUFFER="kill $matches"
    fi
  fi
  zle -K main
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle -N spacezsh.kill.widget

bindkey -M SPACEZSH_KEYMAP "k" spacezsh.kill.widget
bindkey -M SPACEZSH_KEYMAP "K" spacezsh.kill.widget
