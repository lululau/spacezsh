#!/usr/bin/env zsh

spacezsh.emacs.emacsclient-func() {
    if [ "$(uname)" = Darwin ]; then
        emacsclient -s term "$@"
    else
        emacsclient "$@"
    fi
}

spacezsh.emacs.widget.dired() {
    setopt localoptions pipefail 2> /dev/null
    spacezsh.emacs.emacsclient-func -t .
    local dir
    dir=$(spacezsh.emacs.emacsclient-func -e '(when (bound-and-true-p last-dir-for-cli-dir-nav) (print last-dir-for-cli-dir-nav))')
    spacezsh.emacs.emacsclient-func -e '(when (bound-and-true-p last-dir-for-cli-dir-nav) (setq last-dir-for-cli-dir-nav nil))'
    dir=${(Q)dir}
    if [ -n "${~dir}" -a -e ${~dir} ]; then
        cd ${~dir}
    fi
    zle -K main
    zle redisplay
    local ret=$?
    reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    omz_termsupport_precmd
    return $ret
}
zle     -N    spacezsh.emacs.widget.dired

spacezsh.emacs.widget.capture() {
    setopt localoptions pipefail 2> /dev/null
    if [ -n "$TMUX" ]; then
      local capture_cmd='tmux capture-pane -pJS -'
    elif [ $(uname) = Darwin ]; then
      local contents=$(osascript -e "tell app \"iTerm\" to get contents of current session of current tab of current window")
      local capture_cmd='echo "$contents"'
    else
        local capture_cmd='echo'
    fi

    local tmpfile=$(mktemp)
    basename=$(basename "$tmpfile")
    eval "$capture_cmd" | perl -00 -pe 1 > "$tmpfile"
    if [ "$(uname)" = Darwin ]; then
      spacezsh.emacs.emacsclient-func -t -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
      spacezsh.emacs.emacsclient-func -n -e "(kill-buffer \"$basename\")"
    else
        spacezsh.emacs.emacsclient-func -t -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
        spacezsh.emacs.emacsclient-func -n -e "(kill-buffer \"$basename\")"
    fi

    rm "$tmpfile"

    zle -K main
    zle redisplay
    local ret=$?
    reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle     -N    spacezsh.emacs.widget.capture

spacezsh.emacs.widget.search() {
    setopt localoptions pipefail 2> /dev/null
    local elisp="(let ((helm-full-frame t)) (dired \"$PWD\") (spacemacs/helm-files-do-ag \"$PWD\"))"
    if [ "$(uname)" = Darwin ]; then
      emacsclient -t -s term -e "$elisp"
    else
        emacsclient -t -e "$elisp"
    fi
    zle -K main
    zle redisplay
    local ret=$?
    reset-prompt
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}

zle -N spacezsh.emacs.widget.search

if [ -n "$SPACEZSH_EMACS_USE_TUI_AS_VISUAL" ]; then
    export VISUAL=spacezsh.emacs.emacsclient-func
fi

bindkey -M SPACEZSH_KEYMAP "/" spacezsh.emacs.widget.search
bindkey -M SPACEZSH_KEYMAP "ed" spacezsh.emacs.widget.dired
bindkey -M SPACEZSH_KEYMAP "x" spacezsh.emacs.widget.dired
bindkey -M SPACEZSH_KEYMAP "ec" spacezsh.emacs.widget.capture
bindkey -M SPACEZSH_KEYMAP "eo" spacezsh.emacs.widget.capture
bindkey -M SPACEZSH_KEYMAP "ex" edit-command-line

for k (${(k)SPACEZSH_EMACS_EXT_MAPPINGS}); do
    bindkey "$k" "$SPACEZSH_EMACS_EXT_MAPPINGS[$k]"
done
