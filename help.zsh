#!/usr/bin/env zsh

function spacezsh-alias-help() {
  echo
  echo 'SpaceZsh Aliases'
  echo '===================='
  echo
  for k (${(k)SPACEZSH_ALIAS_MAPPINGS}) {
      local key=""
      if [[ "${k[1]}" == $'\e' ]] {
        key=${k//$'\e'/Alt-}
      } else {
        [[ "$k" =~ '(.)(.?)(.?)$' ]] && key="SPC ${match[1]/$'\x7f'/BS} $match[2] $match[3]"
      }
      echo -E "    $key  ==>  ${SPACEZSH_ALIAS_MAPPINGS[$k]}"
  }
}

function spacezsh-dir-help() {
  echo
  echo 'SpaceZsh Directories'
  echo '========================'
  echo
  for k (${(k)SPACEZSH_DIR_MAPPINGS}) {
      local key=""
      if [[ "${k[1]}" == $'\e' ]] {
        key=${k/$'\e'/Alt-}
      } else {
        key="SPC d $k"
      }
      local value=${SPACEZSH_DIR_MAPPINGS[$k]/=>/[COMMAND]}
      echo -E "    $key  ==>  $value"
    }
}

function spacezsh-help() {
  spacezsh-alias-help
  spacezsh-dir-help
}
