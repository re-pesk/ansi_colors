E_RESET='00-00'
E_NORMAL='22-22'
E_ITALIC_OFF='23-23'
E_UNDERLINE_OFF='24-24'
E_BLINK_OFF='25-25'
E_INVERT_OFF='27-27'
E_STRIKE_OFF='29-29'
E_OVERLINE_OFF='55-55'
EF_DEFAULT='39-39'
EB_DEFAULT='49-49'

E_BOLD='01-22'
E_FAINT='02-22'
E_ITALIC='03-23'
E_UNDERLINE='04-24'
E_UNDERLINE_DOUBLE='21-24'
E_BLINK='05-25'
E_INVERT='07-27'
E_HIDE='08-28'
E_STRIKE='09-29'
E_OVERLINE='53-55'

EF_BLACK='30-39'
EF_RED='31-39'
EF_GREEN='32-39'
EF_YELLOW='33-39'
EF_BLUE='34-39'
EF_MAGENTA='35-39'
EF_CYAN='36-39'
EF_WHITE='37-39'
EF_EXT='38;5-39'
EF_RGB='38;2-39'

EB_BLACK='40-49'
EB_RED='41-49'
EB_GREEN='42-49'
EB_YELLOW='43-49'
EB_BLUE='44-49'
EB_MAGENTA='45-49'
EB_CYAN='46-49'
EB_WHITE='47-49'
EB_EXT='48;5-49'
EB_RGB='48;2-49'

E_OFF='[OFF]'
E_SP='[ ]'

ESC_CODE='\033['

ansi_getShellName() {
  echo "$(basename "$(ps -hp "$$" | { read _ _ _ _ cmd _; echo "$cmd"; })" )"
}

ansi_getOnCodes() {
  printf "${1%-*}"
}

ansi_getOffCodes() {
  case "$1" in 
    (*-*) printf "${1#*-}"; return 0 ;; 
  esac
  return 1
}

ansi_sequence() {
  printf "${ESC_CODE}${1}m"
}

ansi_split() (
  string=$1
  delimeter=$2

  shell_name="$(basename "$(ps -hp "$$" | { read _ _ _ _ cmd _; echo "$cmd"; })" )"
  [ $shell_name = "zsh" ] && setopt sh_word_split

  IFS="$delimeter"
  for ansi_codes_pair in $string; do
    printf '%s\n' "${ansi_codes_pair}"
  done
)

ansi_separateOnOffCodes() (
  on_codes=""
  off_codes=""

  for ansi_codes_pair in $(ansi_split "$1" "|"); do
    on_codes="${on_codes:+${on_codes};}$(ansi_getOnCodes "${ansi_codes_pair}")"
    tmp="$(ansi_getOffCodes "${ansi_codes_pair}")"
    [ -n "$tmp" ] && off_codes="${tmp}${off_codes:+;${off_codes}}"
  done

  printf "${on_codes}-${off_codes}"
)

ansi_text() {
  ansi_codes="$(ansi_separateOnOffCodes "$1")"
  on_codes="$(ansi_getOnCodes "${ansi_codes}")"
  off_codes="$(ansi_getOffCodes "${ansi_codes}")"
  shift 1
  # echo "on_codes: '${on_codes}'" >&2
  # echo "off_codes: '${off_codes}'" >&2
  for c; do
    case "$c" in
    ("[OFF]"?*)
      printf "${off_codes:+$(ansi_sequence "${off_codes}")}${c#"[OFF]"}${on_codes:+$(ansi_sequence "${on_codes}")}"
      ;;
    ("[OFF]")
      printf "${off_codes:+$(ansi_sequence "${off_codes}")} ${on_codes:+$(ansi_sequence "${on_codes}")}"
      ;;
    ("[ ]")
      printf "${on_codes:+$(ansi_sequence "${on_codes}")} ${off_codes:+$(ansi_sequence "${off_codes}")}"
      ;;
    (*)
      printf "${on_codes:+$(ansi_sequence "${on_codes}")}${c}${off_codes:+$(ansi_sequence "${off_codes}")}"
      ;;
    esac
  done
}
