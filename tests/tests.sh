#!/bin/sh

DIR_TESTS="$(cd "$(dirname "${0}")" && pwd)"

file_name="_tests.sh"

shell_is_available() (
  result="$(which "$1")"
  [ "${#result}" -lt 1 ] && echo "The '$1' is not installed!" && return 1
  return 0
)

run_script() {
  shell_is_available "$1"
  [ "$?" -eq 0 ] && "$1" "${DIR_TESTS}/${file_name}"
}

clear

run_script dash
# run_script yash
# run_script bash
# run_script ksh
# run_script zsh
# run_script osh
