#!/usr/bin/env zsh

alias issh='SSH_INTERACTIVE=1 ssh'

spacezsh.issh.fzfcmd_complete() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
      echo "fzf-tmux -d${FZF_HEIGHT}" || echo "fzf"
}

spacezsh.issh.widget() {
  local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
  fzf="$(spacezsh.issh.fzfcmd_complete)"
  matches=$(ruby -e 'h=nil;ARGF.readlines.each {|l| l.chomp!; if l=~/^Host\s+\w/; puts h unless h.nil?; h=l.gsub(/^Host\s+/, ""); end; if l=~/^\s+Host[Nn]ame\s+\S/; puts "%-32s [ #{l.gsub(/^\s+Host.ame\s+/,"")} ]" % h; h=nil; end;}' ~/.ssh/config | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} --min-height 15 --reverse $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS" $(__fzfcmd) +m)
  if [ -n "$matches" ]; then
    LBUFFER="SSH_INTERACTIVE=1 ssh ${matches%% *}"
  fi
  zle -K main
  zle accept-line
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle -N spacezsh.issh.widget

bindkey -M SPACEZSH_KEYMAP "S" spacezsh.issh.widget
bindkey $'\es' spacezsh.issh.widget
