#!/bin/sh

DIR_TESTS="$(cd "$(dirname "${0}")" && pwd)"

. "${DIR_TESTS}/_test_helpers.sh"

file_name="${DIR_TESTS}/_tests.sh"

clear

run_script dash "${file_name}"
run_script yash "${file_name}"
run_script bash "${file_name}"
run_script ksh "${file_name}"
run_script zsh "${file_name}"
run_script osh "${file_name}"
