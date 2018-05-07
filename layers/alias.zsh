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
    $'\egs' 'git status\n'
    $'\egd' 'git diff\n'
    $'\egl' 'git log\n'
    $'\egp' 'git log -p\n'
    $'\eg-' 'git checkout -\n'
    $'\eg\eg' 'magit\n'
)


for k (${(k)SPACEZSH_ALIAS_MAPPINGS}); do
    if [[ "$k" =~ '^[a-zA-Z0-9/]+$' ]]; then
        bindkey -s "${SPACEZSH_LEADER}$k" "${SPACEZSH_ALIAS_MAPPINGS[$k]}"
    else
        bindkey -s "$k" "${SPACEZSH_ALIAS_MAPPINGS[$k]}"
    fi
done
