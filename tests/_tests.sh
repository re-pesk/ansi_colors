DIR_SRC="$(cd "$(dirname "${0}")/.." && pwd)"

# shellcheck source=ansi_esc_codes.sh
. "$DIR_SRC/ansi_esc_codes.sh"

show_actual=1

nl='
'
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

test_runColorTests() {
  # E_RESET='00-00'
  # E_BOLD='01-22'
  # E_FAINT='02-22'
  # E_ITALIC='03-23'
  # E_UNDERLINE='04-24'
  # E_UNDERLINE_DOUBLE='21-24'
  # E_OVERLINE='53-55'
  # E_BLINK='05-25'
  # E_INVERT='07-27'
  # E_HIDE='08-28'
  # E_STRIKE='09-29'

  # test_printColors "$E_RESET" $(seq 30 37) | cat -vte >&2
  test_colors "Reset" "$E_RESET" 30 37 "$(cat <<EOF
^[[00m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[00m$
^[[00m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[00m$
EOF
  )"
  echo >&2

  # test_printColors "$E_RESET" $(seq 40 47) | cat -vte >&2
  test_colors "Reset (background)" "$E_RESET" 40 47 "$(cat <<EOF
^[[00m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[00m$
^[[00m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[00m$
EOF
  )"
  echo >&2

  # test_printColors "$E_BOLD" $(seq 30 37) | cat -vte >&2
  test_colors "Bold" "$E_BOLD" 30 37 "$(cat <<EOF
^[[01m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[22m$
^[[22m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[22m$
EOF
  )"
  echo >&2

  # test_printColors "$E_BOLD" $(seq 40 47) | cat -vte >&2
  test_colors "Bold (background)" "$E_BOLD" 40 47 "$(cat <<EOF
^[[01m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[22m$
^[[22m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[22m$
EOF
  )"
  echo >&2

  # test_printColors "$E_FAINT" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Faint" "$E_FAINT" 30 37 "$(
    cat <<EOF
^[[02m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[22m$
^[[22m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[22m$
EOF
  )"
  echo >&2

  # test_printColors "$E_FAINT" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Faint (background)" "$E_FAINT" 40 47 "$(
    cat <<EOF
^[[02m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[22m$
^[[22m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[22m$
EOF
  )"
  echo >&2

  # test_printColors "$E_ITALIC" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Italic" "$E_ITALIC" 30 37 "$(
    cat <<EOF
^[[03m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[23m$
^[[23m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[23m$
EOF
  )"
  echo >&2

  # test_printColors "$E_ITALIC" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Italic (background)" "$E_ITALIC" 40 47 "$(
    cat <<EOF
^[[03m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[23m$
^[[23m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[23m$
EOF
  )"
  echo >&2

  # test_printColors "$E_UNDERLINE" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Underline" "$E_UNDERLINE" 30 37 "$(
    cat <<EOF
^[[04m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[24m$
^[[24m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[24m$
EOF
  )"
  echo >&2

  # test_printColors "$E_UNDERLINE" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Underline (background)" "$E_UNDERLINE" 40 47 "$(
    cat <<EOF
^[[04m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[24m$
^[[24m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[24m$
EOF
  )"
  echo >&2

  # test_printColors "$E_UNDERLINE" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Underline" "$E_UNDERLINE_DOUBLE" 30 37 "$(
    cat <<EOF
^[[21m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[24m$
^[[24m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[24m$
EOF
  )"
  echo >&2

  # test_printColors "$E_UNDERLINE" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Underline (background)" "$E_UNDERLINE_DOUBLE" 40 47 "$(
    cat <<EOF
^[[21m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[24m$
^[[24m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[24m$
EOF
  )"
  echo >&2

  # test_printColors "$E_OVERLINE" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Overline" "$E_OVERLINE" 30 37 "$(
    cat <<EOF
^[[53m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[55m$
^[[55m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[55m$
EOF
  )"
  echo >&2

  # test_printColors "$E_OVERLINE" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Overline (background)" "$E_OVERLINE" 40 47 "$(
    cat <<EOF
^[[53m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[55m$
^[[55m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[55m$
EOF
  )"
  echo >&2

  # test_printColors "$E_BLINK" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Blink" "$E_BLINK" 30 37 "$(
    cat <<EOF
^[[05m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[25m$
^[[25m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[25m$
EOF
  )"
  echo >&2

  # test_printColors "$E_BLINK" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Blink (background)" "$E_BLINK" 40 47 "$(
    cat <<EOF
^[[05m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[25m$
^[[25m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[25m$
EOF
  )"
  echo >&2

  # test_printColors "$E_INVERT" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Invert" "$E_INVERT" 30 37 "$(
    cat <<EOF
^[[07m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[27m$
^[[27m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[27m$
EOF
  )"
  echo >&2

  # test_printColors "$E_INVERT" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Invert (background)" "$E_INVERT" 40 47 "$(
    cat <<EOF
^[[07m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[27m$
^[[27m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[27m$
EOF
  )"
  echo >&2

  # test_printColors "$E_STRIKE" 30 $(seq 30 37) | cat -vte >&2
  test_colors "Strike" "$E_STRIKE" 30 37 "$(
    cat <<EOF
^[[09m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[29m$
^[[29m^[[30m0^[[31m1^[[32m2^[[33m3^[[34m4^[[35m5^[[36m6^[[37m7^[[39m^[[29m$
EOF
  )"
  echo >&2

  # test_printColors "$E_STRIKE" 40 $(seq 40 47) | cat -vte >&2
  test_colors "Strike (background)" "$E_STRIKE" 40 47 "$(
    cat <<EOF
^[[09m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[29m$
^[[29m^[[40m0^[[41m1^[[42m2^[[43m3^[[44m4^[[45m5^[[46m6^[[47m7^[[49m^[[29m$
EOF
  )"
  echo >&2

  # test_printColors "$E_RESET" 90 $(seq 90 97) | cat -vte >&2
  test_colors "Bright Colors" "$E_RESET" 90 97 "$(
    cat <<EOF
^[[00m^[[90m0^[[91m1^[[92m2^[[93m3^[[94m4^[[95m5^[[96m6^[[97m7^[[39m^[[00m$
^[[00m^[[90m0^[[91m1^[[92m2^[[93m3^[[94m4^[[95m5^[[96m6^[[97m7^[[39m^[[00m$
EOF
  )"
  echo >&2

  # test_printColors "$E_RESET" 100 $(seq 100 107) | cat -vte >&2
  test_colors "Bright Colors (background)" "$E_RESET" 100 107 "$(
    cat <<EOF
^[[00m^[[100m0^[[101m1^[[102m2^[[103m3^[[104m4^[[105m5^[[106m6^[[107m7^[[49m^[[00m$
^[[00m^[[100m0^[[101m1^[[102m2^[[103m3^[[104m4^[[105m5^[[106m6^[[107m7^[[49m^[[00m$
EOF
  )"
  echo >&2
  printf ""
  return 0
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
  test_message "The results of running '$1':"; echo >&2
  $output_func "Results: total: ${no}, passed: $((no - sum)), failed: $sum."
  echo >&2
}

clear

test_shell_title
echo

test_report test_runColorTests
