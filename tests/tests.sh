#!/bin/sh

DIR_TESTS="$(cd "$(dirname "${0}")" && pwd)"

. "${DIR_TESTS}/_test_helpers.sh"

test_file="${DIR_TESTS}/_tests.sh"

shell_list="dash yash bash ksh zsh osh"

run_tests_on_shells "$shell_list" "$test_file"
