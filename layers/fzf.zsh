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
    local help="enter: enter dir, alt-enter: accept, space: enter then accept, alt-a: parent directory, alt-h: home, alt-/: root, alt-p: popd, alt-o: last dir,  alt-t: recursive dir, ctrl-t: recursive files"
    local res="$({ gls -Atp --group-directories-first --color=no; [[ -z "$(ls -A | head -c 1)" ]] && echo ../ } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_V_OPTS" fzf +m --header="$PWD" --bind 'alt-enter:accept' --expect 'enter,alt-a,alt-p,alt-h,alt-/,alt-o,space,alt-x,alt-t,ctrl-t' --header="$help")"
    if [[ -z "$res" ]]; then
        zle redisplay
        return 0
    fi

    local should_exit=false
    results=(${(f)res})
    key="${results[1]}"
    file="${results[2]}"

    if [[ "$key" = 'enter' && -d "$file" ]]; then
      cd "$file"
    elif [[ "$key" = 'alt-a' ]]; then
      cd ..
    elif [[ "$key" = 'alt-h' ]]; then
      cd ~
    elif [[ "$key" = 'alt-/' ]]; then
      cd /
    elif [[ "$key" = 'alt-p' ]]; then
      popd -q
    elif [[ "$key" = 'alt-o' ]]; then
      cd -
    elif [[ "$key" = space ]]; then
      cd "$file"
      should_exit=true
    elif [[ "$key" = 'alt-x' || "$key" = 'alt-t' ]]; then
      zle spacezsh.fzf.widget.cd
    elif [[ "$key" = 'ctrl-t' ]]; then
      should_exit=true
      zle spacezsh.fzf.widget.fzf-file-widget-wrapper
    else
      if [[ "$key" = enter ]]; then
        LBUFFER="${LBUFFER}${(q)file} "
      else
        LBUFFER="${LBUFFER}${(q)results[1]} "
      fi
      omz_termsupport_precmd
      reset-prompt
      return 0
    fi

    local ret=$?
    if [[ "$should_exit" = false ]]; then
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
    local help="enter: enter dir, alt-enter: accept, space: enter then accept, alt-a: parent directory, alt-h: home, alt-/: root, alt-p: popd, alt-o: last dir, alt-t: recursive dir, ctrl-t: recursive files"
    local res="$({ gls -Atp --group-directories-first --color=no; [[ -z "$(ls -A | head -c 1)" ]] && echo ../ } | FZF_DEFAULT_OPTS="--height ${FZF_HEIGHT} $FZF_DEFAULT_OPTS $FZF_ALT_V_OPTS" fzf +m --header="$PWD" --bind 'alt-enter:accept' --expect 'enter,alt-a,alt-p,alt-h,alt-/,alt-o,alt-x,alt-t,ctrl-t' --header "$help")"
    if [[ -z "$res" ]]; then
        zle redisplay
        return 0
    fi

    local should_exit=false
    results=(${(f)res})
    key="${results[1]}"
    file="${results[2]}"

    if [[ "$key" = 'enter' && -d "$file" ]]; then
      cd "$file"
    elif [[ "$key" = 'alt-a' ]]; then
      cd ..
    elif [[ "$key" = 'alt-h' ]]; then
      cd ~
    elif [[ "$key" = 'alt-/' ]]; then
      cd /
    elif [[ "$key" = 'alt-p' ]]; then
      popd -q
    elif [[ "$key" = 'alt-o' ]]; then
      cd -
    elif [[ "$key" = 'alt-x' || "$key" = 'alt-t' ]]; then
      should_exit=true
      zle spacezsh.fzf.widget.cd false
    elif [[ "$key" = 'ctrl-t' ]]; then
      should_exit=true
      zle spacezsh.fzf.widget.fzf-file-widget-wrapper
    else
      should_exit=true
      if [[ "$key" = enter && -n "$file" ]]; then
        LBUFFER="${LBUFFER}$(echo ${file:a} | sed 's/^/'\''/;s/$/'\''/') "
      else
        LBUFFER="${LBUFFER}$(echo ${results[1]:a} | sed 's/^/'\''/;s/$/'\''/') "
      fi
      reset-prompt
      return 0
    fi

    local ret=$?
    if [[ "$should_exit" = false ]]; then
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
    prompt_starship_precmd
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
  BUFFER="tmux attach -t '$session'"
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

spacezsh.fzf.widget.rg() {
  local FZF_HEIGHT=$([[ -n "$FZF_TMUX" && -n "$TMUX_PANE" ]] && echo ${FZF_TMUX_HEIGHT:-40%} || echo 100%)
  local RELOAD='reload:rg --column --color=always --smart-case $(echo {q}) || :'
  local OPENER='nvim {1} +{2}'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$word"
  setopt localoptions pipefail 2> /dev/null
  zle -K main
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}
zle     -N   spacezsh.fzf.widget.rg


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
bindkey -M SPACEZSH_KEYMAP "/" spacezsh.fzf.widget.rg

if [[ -z "$SPACEZSH_FZF_EXT_MAPPINGS" ]]; then
  typeset -A SPACEZSH_FZF_EXT_MAPPINGS=() fed
fi

for k (${(k)SPACEZSH_FZF_EXT_MAPPINGS}); do
    bindkey "$k" "$SPACEZSH_FZF_EXT_MAPPINGS[$k]"
done
