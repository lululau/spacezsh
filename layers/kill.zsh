#!/usr/bin/env zsh

spacezsh.kill.fzfcmd_complete() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
      echo "fzf-tmux -d${FZF_HEIGHT}" || echo "fzf"
}

spacezsh.kill.widget() {
  local fzf_expect='enter,ctrl-k,alt-k,ctrl-x,alt-x,ctrl-l,alt-l,alt-t'
  local fzf_header=$'\nShortcuts: enter: select PID,\tctrl-k: kill,\talt-k: sudo kill,\tctrl-x: kill -9,\talt-x: sudo kill -9,\tctrl-l: lsof,\talt-l: sudo lsof\talt-t: pstree'
  local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
  local fzf="$(spacezsh.kill.fzfcmd_complete)"
  local choice=$(ps -ef | sed 1d | FZF_DEFAULT_OPTS="--expect='$fzf_expect' --header='$fzf_header' --header-first --height ${FZF_HEIGHT} --min-height 15 $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS" ${=fzf} -m -e)
  local choices=("${(f)choice}")
  local operation=$choices[1]
  local selections=($choices[2,-1])
  local pids=$(echo "${(F)choices[2,-1]}" | awk -v ORS=' ' '{print $2}')
  if [[ "$operation" = 'enter' ]]; then
    LBUFFER+=$pids
  elif [[ "$operation" = 'ctrl-k' ]]; then
    LBUFFER="kill $pids"
  elif [[ "$operation" = 'alt-k' ]]; then
    LBUFFER="sudo kill $pids"
  elif [[ "$operation" = 'ctrl-x' ]]; then
    LBUFFER="kill -9 $pids"
  elif [[ "$operation" = 'alt-x' ]]; then
    LBUFFER="sudo kill -9 $pids"
  elif [[ "$operation" = 'ctrl-l' ]]; then
    LBUFFER="lsof -Pnp $pids"
  elif [[ "$operation" = 'alt-l' ]]; then
    LBUFFER="sudo lsof -Pnp $pids"
  elif [[ "$operation" = 'alt-t' ]]; then
    LBUFFER="pstree $pids"
  fi
  zle -K main
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle -N spacezsh.kill.widget

bindkey -M SPACEZSH_KEYMAP "k" spacezsh.kill.widget
bindkey -M SPACEZSH_KEYMAP "K" spacezsh.kill.widget
