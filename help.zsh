#!/usr/bin/env zsh

function spacezsh-alias-help() {
  for k (${(k)SPACEZSH_ALIAS_MAPPINGS}) {
      echo -E "Alias: $k  ==>  ${SPACEZSH_ALIAS_MAPPINGS[$k]}"
  }
}

function spacezsh-dir-help() {
  for k (${(k)SPACEZSH_DIR_MAPPINGS}) {
      echo -E "DIR: $k  ==>  ${SPACEZSH_DIR_MAPPINGS[$k]}"
    }
}

function spacezsh-help() {
  spacezsh-alias-help
  spacezsh-dir-help
}
