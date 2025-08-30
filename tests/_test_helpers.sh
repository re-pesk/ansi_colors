NL='
'

test_countLines() (
  multiline_string="$1"
  i=0
  while IFS= read -r line; do
    i=$((i + 1))
  done <<EOF
${multiline_string}
EOF
  echo "$i"
)

test_firstLine() (
  multiline_string="$1"
  while IFS= read -r line; do
    echo "${line}"
    break
  done <<EOF
${multiline_string}
EOF
)

test_lastLine() (
  multiline_string="$1"
  last=""
  while IFS= read -r line; do
    last="${line}"
  done <<EOF
${multiline_string}
EOF
  echo "${last}"
)

test_getLine() (
  multiline_string="$1"
  line_num="$2"
  i=0
  while IFS= read -r line; do
    [ "$i" -eq "${line_num}" ] && echo "${line}" && break
    i=$((i + 1))
  done <<EOF
${multiline_string}
EOF
)

test_shell_title() {
  printf "\n\033[35m|\033[04;53m        $(ansi_getShellName)        \033[55;24m|\033[39m\n" >&2
}

test_title() {
  printf "\n\033[21;35m%s\033[39;24m\n" "$*" >&2
}

test_important() {
  printf "\n\033[04;35m%s\033[39;24m\n\n" "$*" >&2
}

test_message() {
  printf "\n\033[35m%s\033[39m\n\n" "$*" >&2
}

test_success() {
  printf "\033[32m✔ Success! %s\033[39m\n" "$*" >&2
}

test_failure() {
  printf "\033[31m✖ Failure! %s\033[39m\n" "$*" >&2
}

test_summary() {
  printf "\n\033[21;35m%s\033[39;24m\n\n" "$*" >&2
}

test_assert() {
  actual="$1"
  expected="$2"
  title="$3"
  [ ! "$(printf "${actual}" | cat -vte)" = "${expected}" ] && test_failure "Color test '${title}' is failed!" && return 1
  [ -n "${title}" ] && test_success "Color test '${title}' is passed!"
}

test_printColors() {
  ansi_codes="$(ansi_separateOnOffCodes $1)"
  # on="$(ansi_getOnCodes "${ansi_codes}")"
  off="$(ansi_getOffCodes "${ansi_codes}")"
  shift 1
  baseno="$1"
  # echo "ansi_codes: '${ansi_codes}'" >&2
  # echo "on: '$on'" >&2
  # echo "off: '$off'" >&2
  # echo "baseno: '$baseno'" >&2

  default_color="39"
  [ "$baseno" -eq 40 ] && default_color="49"
  [ "$baseno" -eq 100 ] && default_color="49"

  output="$(
    for c; do
      printf "$(ansi_sequence ${c})$((c - baseno))"
    done
  )$(ansi_sequence ${default_color})"

  ansi_text "${ansi_codes}" "${output}"; echo

  output="$(
    for c; do
      printf "$(ansi_sequence ${c})$((c - baseno))"
    done
  )$(ansi_sequence ${default_color})"

  ansi_text "${off}-${off}" "${output}"; echo
}

test_printExtColors() {
  ansi_codes="$1"
  shift 1

  output=""
  for c; do
    printf "$(ansi_text "${ansi_codes}|$c" "$(printf "%03d" "${c}")")"
  done
}

test_colors() {
  title="$1"
  ansi_codes="$2"
  range_start="$3"
  range_end="$4"
  expected="$5"
  test_important "${title}: $(ansi_getOnCodes ${ansi_codes});{${range_start}..${range_end}}"
  actual=$(test_printColors "${ansi_codes}" $(seq ${range_start} ${range_end}))
  [ "$show_actual" -gt 0 ] && printf "$actual\n\n" >&2
  test_assert "$actual\n" "${expected}" "${title}"
  [ "$?" -gt 0 ] && echo 1 && return 1
  echo 0
}

test_extColors() {
  title="$1"
  ansi_codes="$2"
  range_start="$3"
  range_end="$4"
  expected="$5"
  actual=$(test_printExtColors "${ansi_codes}" $(seq ${range_start} ${range_end}))
  [ "$show_actual" -gt 0 ] && printf "$actual\n"
  test_assert "$actual\n" "${expected}" "${title}" 2>&1
  [ "$?" -gt 0 ] && echo 1 && return 1
  echo 0
}

test_other() {
  title="$1"
  actual="$2"
  expected="$3"
  [ "$show_actual" -gt 0 ] && printf "$actual\n"
  test_assert "$actual\n" "${expected}" "${title}" 2>&1
  [ "$?" -gt 0 ] && echo 1 && return 1
  echo 0
}

test_runTests() (
  test_group_name="$1"
  sum=0
  num=0
  for result in $(${test_group_name}); do
    num=$((num + 1))
    sum=$((sum + result))
  done
  echo "${num}-${sum}"
)

test_reportTests() (
  test_group_list="$1"
  test_shell_title

  num=0
  sum=0
  for test_group_name in ${test_group_list}; do
    result="$(test_runTests "${test_group_name}")"
    tests_num=${result%-*}
    tests_sum=${result#*-}
    num=$((num + ${tests_num}))
    sum=$((sum + ${tests_sum}))
    output_func="test_success"
    if [ "${tests_sum}" -gt 0 ]; then
      output_func="test_failure"
    fi
    test_message "Results of running '${test_group_name}':"
    $output_func "Results: total: ${tests_num}, passed: $((tests_num - tests_sum)), failed: $tests_sum."
  done
  test_summary "Total results of all tests running on '$shell_name':"
  output_func="test_success"
  if [ "$sum" -gt 0 ]; then
    output_func="test_failure"
  fi
  $output_func "Results: total: ${num}, passed: $((num - sum)), failed: $sum."
  [ "${sum}" -gt 0 ] && return 1
  return 0
)

shell_is_available() (
  shell_name="$1"
  result="$(which "${shell_name}")"
  [ "${#result}" -lt 1 ] && test_failure "The '${shell_name}' is not installed!" && return 1
  return 0
)

run_script() {
  shell_name="$1"
  test_file="$2"
  shell_is_available "${shell_name}"
  [ "$?" -gt 0 ] && return 1
  "${shell_name}" "${test_file}"
  return $?
}

run_tests_on_shells() {
  shell_list="$1"
  test_file="$2"
  clear

  message_list=""
  for shell_name in $shell_list; do
    message=""
    result="$(run_script "$shell_name" "$test_file")"
    if [ "$?" -gt 0 ]; then
      message="$(test_failure "Some tests on shell '$shell_name' are failed!" 2>&1)"
    else
      message="$(test_success "All tests on shell '$shell_name' are passed!" 2>&1)"
    fi
    message_list="${message_list:+${message_list}${NL}}${message}"
  done

  test_message "====== Tests are finished! ======"

  echo "${message_list}${NL}" >&2
}
