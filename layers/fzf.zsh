#!/usr/bin/env zsh

# ALT-T - Paste the selected file path(s) into the command line
spacezsh.fzf.func.no-recursive() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    setopt localoptions pipefail 2> /dev/null
    ls -atrp | perl -ne 'print unless /^\.\.?\/$/' | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
        echo -n "${(q)item} "
    done
    local ret=$?
    echo
    return $ret
}

spacezsh.fzf.widget.no-recursive() {
    LBUFFER="${LBUFFER}$(spacezsh.fzf.func.no-recursive)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}
zle     -N   spacezsh.fzf.widget.no-recursive

spacezsh.fzf.widget.cd() {
  local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  cd "$dir"
  local ret=$?
  zle reset-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  omz_termsupport_precmd
  return $ret
}
zle     -N    spacezsh.fzf.widget.cd

# # ALT-C - cd into the selected directory(maxdepth=1)
# fzf-cd-widget-1() {
#     local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
#     setopt localoptions pipefail 2> /dev/null
#     local dir="$(ls -dtrp *(/D)| FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_V_OPTS" $(__fzfcmd) +m)"
#     if [[ -z "$dir" ]]; then
#         zle redisplay
#         return 0
#     fi
#     cd "$dir"
#     local ret=$?
#     zle reset-prompt
#     typeset -f zle-line-init >/dev/null && zle zle-line-init
#     omz_termsupport_precmd
#     return $ret
# }

spacezsh.fzf.widget.cd-norecursive() {
    local FZF_HEIGHT=90%
    setopt localoptions pipefail 2> /dev/null
    local res="$({ gls -Atp --group-directories-first --color=no; [[ -z "$(ls -A | head -c 1)" ]] && echo ../ } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_V_OPTS" fzf +m --header="$PWD" --bind 'enter:execute(echo)+accept,alt-enter:accept,alt-a:execute(echo cd ..)+accept,alt-p:execute(echo popd -q)+accept,alt-h:execute(echo cd __HOME_IN_FZF__)+accept,alt-/:execute(echo cd __ROOT_IN_FZF__)+accept,alt-o:execute(echo cd -)+accept,space:execute(echo exit)+accept')"
    if [[ -z "$res" ]]; then
        zle redisplay
        return 0
    fi

    file="${res#$'\n'}"

    if [[ "$res[1]" = $'\n' && -d "$file" ]]; then
      cd "$file"
    elif [[ "$res" = $'cd ..'* ]]; then
      cd ..
    elif [[ "$res" = $'cd __HOME_IN_FZF__'* ]]; then
      cd ~
    elif [[ "$res" = $'cd __ROOT_IN_FZF__'* ]]; then
      cd /
    elif [[ "$res" = $'popd -q'* ]]; then
      popd -q
    elif [[ "$res" = $'cd -'* ]]; then
      cd -
    elif [[ "$res" = $'exit\n'* ]]; then
      cd "${res#$'exit\n'}"
    else
      LBUFFER="${LBUFFER}${(q)file}"
      omz_termsupport_precmd
      return 0
    fi

    local ret=$?
    if [[ "$res[1]" = $'\n' || "$res" = $'cd ..\n'* || "$res" = $'popd -q\n'* || "$res" = $'cd -\n'* || "$res" = $'cd __HOME_IN_FZF__'* || "$res" = $'cd __ROOT_IN_FZF__'* ]]; then
        spacezsh.fzf.widget.cd-norecursive false
    fi
    if [[ "$1" != false ]]; then
      zle reset-prompt
      typeset -f zle-line-init >/dev/null && zle zle-line-init
    fi
    omz_termsupport_precmd
    return $ret
}
zle     -N    spacezsh.fzf.widget.cd-norecursive

spacezsh.fzf.widget.select-dir-no-recursive() {
    local old_pwd=$PWD
    local old_lbuffer=$LBUFFER
    local FZF_HEIGHT=90%
    setopt localoptions pipefail 2> /dev/null
    local res="$({ gls -Atp --group-directories-first --color=no; [[ -z "$(ls -A | head -c 1)" ]] && echo ../ } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_V_OPTS" fzf +m --header="$PWD" --bind 'enter:execute(echo)+accept,alt-enter:accept,alt-a:execute(echo cd ..)+accept,alt-p:execute(echo popd -q)+accept,alt-h:execute(echo cd __HOME_IN_FZF__)+accept,alt-/:execute(echo cd __ROOT_IN_FZF__)+accept,alt-o:execute(echo cd -)+accept')"
    if [[ -z "$res" ]]; then
        zle redisplay
        return 0
    fi

    file="${res#$'\n'}"

    if [[ "$res[1]" = $'\n' && -d "$file" ]]; then
      cd "$file"
    elif [[ "$res" = $'cd ..'* ]]; then
      cd ..
    elif [[ "$res" = $'cd __HOME_IN_FZF__'* ]]; then
      cd ~
    elif [[ "$res" = $'cd __ROOT_IN_FZF__'* ]]; then
      cd /
    elif [[ "$res" = $'popd -q'* ]]; then
      popd -q
    elif [[ "$res" = $'cd -'* ]]; then
      cd -
    else
      LBUFFER="${LBUFFER}$(echo ${file:a} | sed 's/^/'\''/;s/$/'\''/')"
      return 0
    fi

    local ret=$?
    if [[ "$res[1]" = $'\n' || "$res" = $'cd ..\n'* || "$res" = $'popd -q\n'* || "$res" = $'cd -\n'* || "$res" = $'cd __HOME_IN_FZF__'* || "$res" = $'cd __ROOT_IN_FZF__'* ]]; then
        spacezsh.fzf.widget.select-dir-no-recursive false
    fi
    if [[ "$1" != false ]]; then
      quit_pwd=$PWD
      cd "$old_pwd"
      if [ "$LBUFFER" = "$old_lbuffer" ]; then
        LBUFFER="${LBUFFER}$(echo ${quit_pwd:a} | sed 's/^/'\''/;s/$/'\''/')"
      fi
      zle reset-prompt
      typeset -f zle-line-init >/dev/null && zle zle-line-init
    fi
    return $ret
}
zle     -N    spacezsh.fzf.widget.select-dir-no-recursive

spacezsh.fzf.widget.auotjump() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    setopt localoptions pipefail 2> /dev/null
    local tac_cmd=tac
    if [ $(uname) = Darwin ]; then
      tac_cmd=gtac
    fi
    local dir=$({ dirs -pl; autojump -s | sed -n '/^_______/!p; /^_______/q'  | $tac_cmd | cut -d$'\t' -f2; } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_J_OPTS" $(__fzfcmd) +m)
    if [[ -z "$dir" || ! -e "$dir" ]]; then
        zle redisplay
        return 0
    fi
    cd "$dir"
    local ret=$?
    zle reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}

zle     -N   spacezsh.fzf.widget.auotjump

spacezsh.fzf.widget.select-dir-autojump() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    local tac_cmd=tac
    if [ $(uname) = Darwin ]; then
      tac_cmd=gtac
    fi
    LBUFFER="${LBUFFER}$({dirs -pl; autojump -s | sed -n '/^_______/!p; /^_______/q' | $tac_cmd  | cut -d$'\t' -f2; } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_J_OPTS" $(__fzfcmd) +m | sed "s#^#'#;s#\$#'#")"
    zle redisplay
}
zle     -N   spacezsh.fzf.widget.select-dir-autojump

spacezsh.fzf.widget.capture() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    if [ -n "$TMUX" ]; then
      capture_cmd='tmux capture-pane -pS -'
    elif [ $(uname) = Darwin ]; then
      local contents=$(osascript -e "tell app \"iTerm\" to get contents of current session of current tab of current window")
      capture_cmd='echo "$contents"'
    else
      capture_cmd='echo'
    fi
    LBUFFER="${LBUFFER}$(eval "$capture_cmd" | perl -00 -pe 1 | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_O_OPTS" $(__fzfcmd) +m --tac | sed "s#^➜ *##;s#^#'#;s#\$#'#")"
    zle redisplay
}
zle     -N   spacezsh.fzf.widget.capture

spacezsh.fzf.widget.git-checkout() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    setopt localoptions pipefail 2> /dev/null
    local branch=$(git branch | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_J_OPTS" $(__fzfcmd) +m | sed "s#.* ##")
    if [[ -z "$branch" ]]; then
        zle redisplay
        return 0
    fi
    git checkout "$branch"
    local ret=$?
    zle reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle     -N   spacezsh.fzf.widget.git-checkout

bindkey "${SPACEZSH_LEADER}fg" spacezsh.fzf.widget.git-checkout
bindkey "${SPACEZSH_LEADER}fC" spacezsh.fzf.widget.select-dir-no-recursive
bindkey "${SPACEZSH_LEADER}ft" spacezsh.fzf.widget.no-recursive
bindkey "${SPACEZSH_LEADER}fd" spacezsh.fzf.widget.cd
bindkey "${SPACEZSH_LEADER}fc" spacezsh.fzf.widget.cd-norecursive
bindkey "${SPACEZSH_LEADER}fj" spacezsh.fzf.widget.auotjump
bindkey "${SPACEZSH_LEADER}fJ" spacezsh.fzf.widget.select-dir-autojump
bindkey "${SPACEZSH_LEADER}fo" spacezsh.fzf.widget.capture
bindkey "${SPACEZSH_LEADER}ff" fzf-file-widget

if [[ -z "$SPACEZSH_FZF_EXT_MAPPINGS" ]]; then
  typeset -A SPACEZSH_FZF_EXT_MAPPINGS=()
fi

for k (${(k)SPACEZSH_FZF_EXT_MAPPINGS}); do
    bindkey "$k" "$SPACEZSH_FZF_EXT_MAPPINGS[$k]"
done
