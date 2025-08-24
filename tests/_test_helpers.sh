nl='
'

test_firstLine() (
  while IFS= read -r line; do
    echo "$line"
    break
  done <<EOF
$1
EOF
)

test_lastLine() (
  last=""
  while IFS= read -r line; do
    last="$line"
  done <<EOF
$1
EOF
  echo "$last"
)

test_getLine() (
  i=0
  while IFS= read -r line; do
    # echo "line='$line'\n"
    # echo "i='$i'\n"
    [ "$i" -eq "$2" ] && echo "$line" && break
    i=$((i + 1))
  done <<EOF
$1
EOF
)

test_shell_title() {
  printf "\033[35m|\033[04;53m        $(ansi_getShellName)        \033[55;24m|\033[39m\n" >&2
}

test_title() {
  printf "\033[04;35m%s\033[00m\n" "$*" >&2
}

test_message() {
  printf "\033[35m%s\033[00m\n" "$*" >&2
}

test_success() {
  printf "\033[32m✔ Success! %s\033[00m\n" "$*" >&2
}

test_failure() {
  printf "\033[31m✖ Failure! %s\033[00m\n" "$*" >&2
}

test_assert() {
  [ ! "$(printf "$1" | cat -vte)" = "$(
    cat <<EOF
$2
EOF
  )" ] && test_failure "Color test '$3' is failed!" && return 1
  [ -n "$3" ] && test_success "Color test '$3' is passed!"
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

  ansi_text "${ansi_codes}" "${output}"
  echo

  output="$(
    for c; do
      printf "$(ansi_sequence ${c})$((c - baseno))"
    done
  )$(ansi_sequence ${default_color})"

  ansi_text "${off}-${off}" "${output}"
  echo
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
  test_title "$1: $(ansi_getOnCodes $2);{$3..$4}"
  echo >&2
  actual=$(test_printColors "$2" $(seq $3 $4))
  [ "$show_actual" -gt 0 ] && printf "$actual\n" >&2
  echo >&2
  test_assert "$actual\n" "$5" "$1"
  [ "$?" -gt 0 ] && echo 1 && return 1
  echo 0
}

test_extColors() {
  actual=$(test_printExtColors "$2" $(seq $3 $4))
  [ "$show_actual" -gt 0 ] && printf "$actual\n"
  test_assert "$actual\n" "$5" "$1" 2>&1
  [ "$?" -gt 0 ] && echo 1 && return 1
  echo 0
}

test_report () {
  sum=0
  no=0
  for result in $($1); do
    no=$((no + 1))
    sum=$((sum + result))
  done
  output_func="test_success"
  if [ "$sum" -gt 0 ]; then
    output_func="test_failure"
    echo
  fi
  test_message "The results of '$1':"; echo >&2
  $output_func "Results: total: ${no}, passed: $((no - sum)), failed: $sum."
  echo >&2
}

shell_is_available() (
  shell_name="$1"
  result="$(which "${shell_name}")"
  [ "${#result}" -lt 1 ] && echo "The '${shell_name}' is not installed!" && return 1
  return 0
)

run_script() {
  shell_name="$1"
  file_name="$2"
  shell_is_available "${shell_name}"
  [ "$?" -eq 0 ] && "${shell_name}" "${file_name}"
}
