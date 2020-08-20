#!/usr/bin/env zsh

function spacezsh.nnn.n() {
  if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
    echo "nnn is already running"
    return
  fi
  if [ -z "$NNN_ENV_DEFINED" ]; then
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_BMS="a:/Applications/;b:~/blog/;B:~/bin;c:~/.config;C:~/cascode;d:~/Downloads;D:~/Documents;e:~/.emacs.d;F:~/Cafe;g:~/cascode/github.com;j:~/kt/fc;k:~/kt;l:~/Library/Application Support;L:~/Library/Preferences;m:~/Movies;r:~/.tmux-resurrect;s:~/Documents/scratches;S:~/snips;t:~/tmp;T:~/.Trash;v:/Volumes;z:~/.spacezsh;Z:~/.oh-my-zsh;m:~/Movies;"
    export NNN_TRASH=1
    export NNN_FIFO='/tmp/nnn.fifo'
    export NNN_ARCHIVE="\\.(7z|bz2|gz|tar|tgz|zip)$"
    export NNN_PLUG='f:finder;z:fzcd;p:preview-tui'
    export NNN_USE_EDITOR=1
    export NNN_COPIER=$HOME/bin/copier_for_nnn.sh
    # export NNN_DE_FILE_MANAGER=open
    # export NNN_NOWAIT=1

    export NNN_ENV_DEFINED=1
  fi

  nnn "$@"

  if [ -f $NNN_TMPFILE ]; then
    . $NNN_TMPFILE
    rm -f $NNN_TMPFILE > /dev/null
  fi
}

spacezsh.nnn.widget() {
  zle -K main
  setopt localoptions pipefail 2> /dev/null
  BUFFER=spacezsh.nnn.n
  zle accept-line
  local ret=$?
  reset-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N    spacezsh.nnn.widget

bindkey -M SPACEZSH_KEYMAP "n" spacezsh.nnn.widget
bindkey $'\en' spacezsh.nnn.widget


if [[ -z "$SPACEZSH_NNN_EXT_MAPPINGS" ]]; then
  typeset -A SPACEZSH_NNN_EXT_MAPPINGS=()
fi

for k (${(k)SPACEZSH_NNN_EXT_MAPPINGS}); do
  bindkey "$k" "$SPACEZSH_NNN_EXT_MAPPINGS[$k]"
done
