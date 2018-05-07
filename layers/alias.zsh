#!/usr/bin/env zsh

typeset -A SPACEZSH_ALIAS_MAPPINGS=(
    # ls
    'll' 'l\n'
    'lL' 'ls\n'
    'l1' 'ls -1\n'
    'lr' 'l -tr\n'
    'lR' 'la -tr\n'
    'la' 'la\n'
    $'\eL' 'ls\n'
    $'\el\el' 'l\n'
    $'\elr' 'l -tr\n'
    $'\el\er' 'la -tr\n'
    $'\ela' 'la\n'

    # ssh-dialog
    'ss' 'ss\n'
    $'\es' 'ss\n'

    # git
    'gs' 'git status\n'
    'gd' 'git diff\n'
    'gl' 'git log\n'
    'gp' 'git log -p\n'
    'g-' 'git checkout -\n'
    'gg' 'magit\n'
    'gr' 'git remote -vvv\n'
    'gb' 'git branch -vvv\n'
    'gL' 'git pull\n'
    'gP' 'git push\n'
    $'\egs' 'git status\n'
    $'\egd' 'git diff\n'
    $'\egl' 'git log\n'
    $'\egp' 'git log -p\n'
    $'\eg-' 'git checkout -\n'
    $'\eg\eg' 'magit\n'

    # Homebrew
    'bu' 'brew update && brew outdated\n'
    'bU' 'brew upgrade && brew cleanup\n'
    'bi' 'brew info '
    'bl' 'brew list\n'
    'b/' 'brew list | ag '
    'bsl' 'brew services list\n'
    'bss' 'brew services start '
    'bse' 'brew services stop '

    'ps' 'ps -ef | ag '

    'xa' 'cat _@_ | ag '
    'xb' 'bat _@_\n'
    'xh' 'head _@_ | '
    'xi' 'cat _@_ | iconv -f GBK '
    'xI' 'head _@_ | iconv -f GBK '
    'xt' 'tail -f _@_\n'
    'xw' 'wc -l _@_\n'
)

function spacezsh.alias.widget() {
    local args=(${(z)BUFFER})
    if [[ "${KEYS[1,2]}" = "$SPACEZSH_LEADER" ]]; then
      local key=$KEYS[3,-1]
    else
        local key=$KEYS
    fi
    local value=$SPACEZSH_ALIAS_MAPPINGS[$key]
    if [[ "$value" =~ _@_ ]]; then
      value=${value//_@_/$BUFFER}
    else
        for i ({1..10}); do
            if [[ "$value" =~ _$i_ ]]; then
              value=${value//_$i_/$args[$i]}
            fi
        done
    fi

    BUFFER=''

    if [ "$value[-2,-1]" = '\n' ]; then
        LBUFFER=$value[1,-3]
        zle accept-line
    else
        LBUFFER=$value
    fi

    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
}

zle -N spacezsh.alias.widget

for k (${(k)SPACEZSH_ALIAS_MAPPINGS}); do
    if [[ "$k" =~ '^[a-zA-Z0-9/]+$' ]]; then
        bindkey "${SPACEZSH_LEADER}$k" spacezsh.alias.widget
    else
        bindkey "$k" spacezsh.alias.widget
    fi
done
