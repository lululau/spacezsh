#!/usr/bin/env zsh

bindkey -s '\eL' 'ls\n'
bindkey -s '\el\el' 'l\n'
bindkey -s '\elr' 'l -tr\n'
bindkey -s '\el\er' 'la -tr\n'
bindkey -s '\ela' 'la\n'
bindkey -s '\es' 'ss\n'

bindkey -s '\egs' 'git status\n'
bindkey -s '\egd' 'git diff\n'
bindkey -s '\egl' 'git log\n'
bindkey -s '\egp' 'git log -p\n'
bindkey -s '\eg-' 'git checkout -\n'
bindkey -s '\eg\eg' 'magit\n'
