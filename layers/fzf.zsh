#!/usr/bin/env zsh

# ALT-T - Paste the selected file path(s) into the command line
spacezsh.fzf.func.no-recursive() {
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    setopt localoptions pipefail 2> /dev/null
    ls -atrp | perl -ne 'print unless /^\.\.?\/$/' | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
        echo -n "${(q)item} "
    done
    zle -K main
    local ret=$?
    echo
    return $ret
}

spacezsh.fzf.widget.no-recursive() {
    LBUFFER="${LBUFFER}$(spacezsh.fzf.func.no-recursive) "
    zle -K main
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
    -o -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  if [[ -d "$dir" ]]; then
    cd "$dir"
    spacezsh_fzf_widget_selected_file_base_name=''
  else
    cd "$dir:h"
    if [[ "$1" == false ]]; then
      spacezsh_fzf_widget_selected_file_base_name=/$dir:t
    fi
  fi
  zle -K main
  local ret=$?
  reset-prompt
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
#     zle -K main
#     cd "$dir"
#     local ret=$?
#     reset-prompt
#     typeset -f zle-line-init >/dev/null && zle zle-line-init
#     omz_termsupport_precmd
#     return $ret
# }

spacezsh.fzf.widget.cd-norecursive() {
    zle -K main
    local FZF_HEIGHT=90%
    setopt localoptions pipefail 2> /dev/null
    local res="$({ gls -Atp --group-directories-first --color=no; [[ -z "$(ls -A | head -c 1)" ]] && echo ../ } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_V_OPTS" fzf +m --header="$PWD" --bind 'enter:execute(echo)+accept,alt-enter:accept,alt-a:execute(echo cd ..)+accept,alt-p:execute(echo popd -q)+accept,alt-h:execute(echo cd __HOME_IN_FZF__)+accept,alt-/:execute(echo cd __ROOT_IN_FZF__)+accept,alt-o:execute(echo cd -)+accept,space:execute(echo exit)+accept,alt-x:execute(echo cd-widget)+accept,ctrl-t:execute(echo fzf-file)+accept')"
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
    elif [[ "$res" = $'cd-widget'* ]]; then
      zle spacezsh.fzf.widget.cd
    elif [[ "$res" = $'fzf-file'* ]]; then
      zle spacezsh.fzf.widget.fzf-file-widget-wrapper
    else
      LBUFFER="${LBUFFER}${(q)file} "
      omz_termsupport_precmd
      reset-prompt
      return 0
    fi

    local ret=$?
    if [[ "$res[1]" = $'\n' || "$res" = $'cd ..\n'* || "$res" = $'popd -q\n'* || "$res" = $'cd -\n'* || "$res" = $'cd __HOME_IN_FZF__'* || "$res" = $'cd __ROOT_IN_FZF__'* ]]; then
        spacezsh.fzf.widget.cd-norecursive false
    fi
    if [[ "$1" != false ]]; then
      reset-prompt
      typeset -f zle-line-init >/dev/null && zle zle-line-init
    fi
    omz_termsupport_precmd
    return $ret
}
zle     -N    spacezsh.fzf.widget.cd-norecursive

spacezsh.fzf.widget.select-dir-no-recursive() {
    zle -K main
    local old_pwd=$PWD
    local old_lbuffer=$LBUFFER
    local FZF_HEIGHT=90%
    setopt localoptions pipefail 2> /dev/null
    local res="$({ gls -Atp --group-directories-first --color=no; [[ -z "$(ls -A | head -c 1)" ]] && echo ../ } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_V_OPTS" fzf +m --header="$PWD" --bind 'enter:execute(echo)+accept,alt-enter:accept,alt-a:execute(echo cd ..)+accept,alt-p:execute(echo popd -q)+accept,alt-h:execute(echo cd __HOME_IN_FZF__)+accept,alt-/:execute(echo cd __ROOT_IN_FZF__)+accept,alt-o:execute(echo cd -)+accept,alt-x:execute(echo cd-widget)+accept,ctrl-t:execute(echo cd-widget)+accept')"
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
    elif [[ "$res" = $'cd-widget'* ]]; then
      zle spacezsh.fzf.widget.cd false
    else
      LBUFFER="${LBUFFER}$(echo ${file:a} | sed 's/^/'\''/;s/$/'\''/') "
      reset-prompt
      return 0
    fi

    local ret=$?
    if [[ "$res[1]" = $'\n' || "$res" = $'cd ..\n'* || "$res" = $'popd -q\n'* || "$res" = $'cd -\n'* || "$res" = $'cd __HOME_IN_FZF__'* || "$res" = $'cd __ROOT_IN_FZF__'* ]]; then
        spacezsh.fzf.widget.select-dir-no-recursive false
    fi
    if [[ "$1" != false ]]; then
      quit_pwd=$PWD${spacezsh_fzf_widget_selected_file_base_name}
      cd "$old_pwd"
      if [ "$LBUFFER" = "$old_lbuffer" ]; then
        LBUFFER="${LBUFFER}$(echo ${quit_pwd:a} | sed 's/^/'\''/;s/$/'\''/') "
      fi
      reset-prompt
      typeset -f zle-line-init >/dev/null && zle zle-line-init
    fi
    return $ret
}
zle     -N    spacezsh.fzf.widget.select-dir-no-recursive

spacezsh.fzf.widget.auotjump() {
    zle -K main
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
    starship_precmd
    reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}

zle     -N   spacezsh.fzf.widget.auotjump

spacezsh.fzf.widget.select-dir-autojump() {
    zle -K main
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    local tac_cmd=tac
    if [ $(uname) = Darwin ]; then
      tac_cmd=gtac
    fi
    LBUFFER="${LBUFFER}$({dirs -pl; autojump -s | sed -n '/^_______/!p; /^_______/q' | $tac_cmd  | cut -d$'\t' -f2; } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_J_OPTS" $(__fzfcmd) +m | sed "s#^#'#;s#\$#'#") "
    zle redisplay
}
zle     -N   spacezsh.fzf.widget.select-dir-autojump

spacezsh.fzf.widget.capture() {
    zle -K main
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    if [ -n "$TMUX" ]; then
      capture_cmd='tmux capture-pane -pS -'
    elif [ $(uname) = Darwin ]; then
      local contents=$(osascript -e "tell app \"iTerm\" to get contents of current session of current tab of current window")
      capture_cmd='echo "$contents"'
    else
      capture_cmd='echo'
    fi
    LBUFFER="${LBUFFER}$(eval "$capture_cmd" | perl -00 -pe 1 | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_O_OPTS" $(__fzfcmd) +m --tac | sed "s#^➜ *##;s#^#'#;s#\$#'#") "
    zle redisplay
}
zle     -N   spacezsh.fzf.widget.capture

spacezsh.fzf.widget.git-checkout() {
    zle -K main
    local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
    setopt localoptions pipefail 2> /dev/null
    local branch=$(git branch | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_J_OPTS" $(__fzfcmd) +m | sed "s#.* ##")
    if [[ -z "$branch" ]]; then
        zle redisplay
        return 0
    fi
    git checkout "$branch"
    local ret=$?
    reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle     -N   spacezsh.fzf.widget.git-checkout

spacezsh.fzf.widget.tmux_attach_session() {
  zle -K main
  local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
  setopt localoptions pipefail 2> /dev/null
  local session=$(tmux list-sessions -F '#S' | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_J_OPTS" $(__fzfcmd) +m)
  if [[ -z "$session" ]]; then
    zle redisplay
    return 0
  fi
  BUFFER="tmux attach -t $session"
  zle accept-line
}
zle     -N    spacezsh.fzf.widget.tmux_attach_session

spacezsh.fzf.widget.fzf-file-widget-wrapper() {
  zle -K main
  zle fzf-file-widget
}
zle     -N   spacezsh.fzf.widget.fzf-file-widget-wrapper

get-java-class-name() {
    while { read line; } {
            local name=${line:a}
            name=${name#*/src/}
            name=${name#*main/java/}
            name=${name#*main/resources/}
            name=${name#*test/java/}
            name=${name#*test/resources/}
            name=${name#*/target/}
            name=${name#*classes/}
            name=${name%.java}
            name=${name%.class}
            name=${name//\//.}
            echo $name
    }
}

spacezsh.fzf.widget.java-class-names() {
  local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
  local cmd="command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
        -o -type d -o \( -name '*.java' -o -name '*.class' \) -print 2> /dev/null | cut -b3- | get-java-class-name"
  setopt localoptions pipefail 2> /dev/null
  local class="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  LBUFFER="${BUFFER% } $class"
  zle -K main
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle     -N    spacezsh.fzf.widget.java-class-names

bindkey -M SPACEZSH_KEYMAP "gc" spacezsh.fzf.widget.git-checkout
bindkey -M SPACEZSH_KEYMAP "zC" spacezsh.fzf.widget.select-dir-no-recursive
bindkey -M SPACEZSH_KEYMAP "zT" spacezsh.fzf.widget.no-recursive
bindkey -M SPACEZSH_KEYMAP "zd" spacezsh.fzf.widget.cd
bindkey -M SPACEZSH_KEYMAP "zx" spacezsh.fzf.widget.cd
bindkey -M SPACEZSH_KEYMAP "zc" spacezsh.fzf.widget.cd-norecursive
bindkey -M SPACEZSH_KEYMAP "c" spacezsh.fzf.widget.cd-norecursive
bindkey -M SPACEZSH_KEYMAP "zj" spacezsh.fzf.widget.auotjump
bindkey -M SPACEZSH_KEYMAP "j" spacezsh.fzf.widget.auotjump
bindkey -M SPACEZSH_KEYMAP "zJ" spacezsh.fzf.widget.select-dir-autojump
bindkey -M SPACEZSH_KEYMAP "zo" spacezsh.fzf.widget.capture
bindkey -M SPACEZSH_KEYMAP "ta" spacezsh.fzf.widget.tmux_attach_session
bindkey -M SPACEZSH_KEYMAP "zf" spacezsh.fzf.widget.fzf-file-widget-wrapper
bindkey -M SPACEZSH_KEYMAP "zt" spacezsh.fzf.widget.fzf-file-widget-wrapper
bindkey -M SPACEZSH_KEYMAP "zJ" spacezsh.fzf.widget.java-class-names

if [[ -z "$SPACEZSH_FZF_EXT_MAPPINGS" ]]; then
  typeset -A SPACEZSH_FZF_EXT_MAPPINGS=()
fi

for k (${(k)SPACEZSH_FZF_EXT_MAPPINGS}); do
    bindkey "$k" "$SPACEZSH_FZF_EXT_MAPPINGS[$k]"
done
