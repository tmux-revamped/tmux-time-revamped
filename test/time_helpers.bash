#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

EPOCH_OCT_16=1792161000
EPOCH_OCT_17=1792247400
EPOCH_OCT_30=1793361600
EPOCH_MAR_07=1772884800

setup() {
  harness_setup
  for name in $(compgen -v TIME_REVAMPED_); do
    unset "${name}"
  done
  FAKE="${BATS_TEST_TMPDIR}/fake"
  export HOME="${BATS_TEST_TMPDIR}/home" FAKE
  export TZ=UTC
  unset KODOUGU_THEME KODOUGU_ACCENT NO_COLOR
  export REVAMPED_TEST_GUM_LOG="${BATS_TEST_TMPDIR}/gum.log"
  : >"${REVAMPED_TEST_GUM_LOG}"
  mkdir -p "${HOME}" "${FAKE}" "${BATS_TEST_TMPDIR}/stubs"
  UNTRACED='{ set +x; } 2>/dev/null'
  printf '3.6\n' >"${FAKE}/version"
  : >"${FAKE}/vars"
  : >"${FAKE}/log"
  now "${EPOCH_OCT_16}"
  fake_tmux
  fake_date gnu
  harness_hide osascript notify-send pbcopy wl-copy xclip curl cal
}

quiet() {
  printf '#!/bin/sh\n%s\n%s\n' "${UNTRACED}" "$2" >"${BATS_TEST_TMPDIR}/stubs/$1"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/$1"
}

var() {
  local kept
  kept=$(grep -v "^$1	" "${FAKE}/vars" || :)
  printf '%s\n%s\t%s\n' "${kept}" "$1" "$2" | grep -v '^$' >"${FAKE}/vars.tmp"
  mv -f "${FAKE}/vars.tmp" "${FAKE}/vars"
}

value() {
  awk -F '\t' -v want="$1" '$1 == want { print $2 }' "${FAKE}/vars"
}

option() {
  var "@time_revamped_$1" "$2"
}

held() {
  value "@time_revamped_$1"
}

now() {
  printf '%s\n' "$1" >"${FAKE}/now"
}

without() {
  rm -f "${BATS_TEST_TMPDIR}/farm/$1"
}

unstub() {
  rm -f "${BATS_TEST_TMPDIR}/stubs/$1"
}

fake_date() {
  local gnu=0 probe
  probe=$(/bin/date -d @0 +%s 2>/dev/null) || probe=""
  [[ "${probe}" == 0 ]] && gnu=1
  quiet date 'mode='"$1"'
real_gnu='"${gnu}"'
at() {
  stamp=$1
  shift
  if [ "${real_gnu}" = 1 ]; then
    exec /bin/date -d "@${stamp}" "$@"
  fi
  exec /bin/date -r "${stamp}" "$@"
}
case "${1:-}" in
-d)
  [ "${mode}" = gnu ] || exit 1
  stamp=${2#@}
  ! grep -qx "${stamp}" "'"${FAKE}"'/fail" 2>/dev/null || exit 1
  shift 2
  at "${stamp}" "$@"
  ;;
-r)
  [ "${mode}" = bsd ] || exit 1
  stamp=$2
  ! grep -qx "${stamp}" "'"${FAKE}"'/fail" 2>/dev/null || exit 1
  shift 2
  at "${stamp}" "$@"
  ;;
*)
  read -r stamp <"'"${FAKE}"'/now"
  at "${stamp}" "$@"
  ;;
esac'
}

macos() {
  export REVAMPED_TEST_UNAME_S=Darwin
}

linux() {
  export REVAMPED_TEST_UNAME_S=Linux
}

fake_tmux() {
  cat >"${BATS_TEST_TMPDIR}/stubs/tmux" <<EOF
#!/bin/sh
${UNTRACED}
printf '%s\n' "\$*" >>"${FAKE}/log"
expanded() {
  printf '%s\n' "\$1" | awk -v vars="${FAKE}/vars" '
    BEGIN { while ((getline row < vars) > 0) { at = index(row, "\t"); value[substr(row, 1, at - 1)] = substr(row, at + 1) } }
    {
      line = \$0
      out = ""
      while ((at = index(line, "#{")) > 0) {
        stop = index(substr(line, at), "}")
        name = substr(line, at + 2, stop - 3)
        out = out substr(line, 1, at - 1) value[name]
        line = substr(line, at + stop)
      }
      print out line
    }
  '
}
looked() {
  awk -F '\t' -v want="\$1" '\$1 == want { print \$2 }' "${FAKE}/vars"
}
put() {
  kept=\$(grep -v "^\$1	" "${FAKE}/vars" || :)
  printf '%s\n%s\t%s\n' "\${kept}" "\$1" "\$2" | grep -v '^\$' >"${FAKE}/vars.tmp"
  mv -f "${FAKE}/vars.tmp" "${FAKE}/vars"
}
written() {
  while [ "\$#" -gt 0 ]; do
    if [ "\$1" = set-option ] && [ "\${2:-}" = -gq ] && [ "\$#" -ge 4 ]; then
      put "\$3" "\$4"
      shift 4
      continue
    fi
    shift
  done
}
case "\$1" in
-V)
  IFS= read -r version <"${FAKE}/version"
  printf 'tmux %s\n' "\${version}"
  ;;
display-message)
  [ "\$2" != -p ] || expanded "\$3"
  ;;
show-option)
  looked "\$3"
  ;;
list-keys)
  [ ! -f "${FAKE}/keys" ] || cat "${FAKE}/keys"
  ;;
list-clients)
  [ ! -f "${FAKE}/clients" ] || cat "${FAKE}/clients"
  ;;
*)
  case "\$*" in
  *" ; "*) [ ! -f "${FAKE}/refused" ] || exit 1 ;;
  *) [ ! -f "${FAKE}/refused" ] || ! grep -qF -- "\$*" "${FAKE}/refused" || exit 1 ;;
  esac
  written "\$@"
  ;;
esac
exit 0
EOF
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"
}

tmux_is() {
  printf '%s\n' "$1" >"${FAKE}/version"
}

load_plugin() {
  lib_run time "${1:-}"'time_revamped_load'
}

planned() {
  lib_run time "${1:-}"'time_revamped_plan; time_revamped_lines'
}

reading() {
  lib_run time "${2:-}"'time_revamped_load; time_revamped_show '"$1"
}

sends() {
  grep -v -e '^display-message -p' -e '^-V' -e '^list-' -e '^show-option' "${FAKE}/log" || :
}

sent() {
  grep -c -- "$1" "${FAKE}/log" || :
}

tool() {
  # shellcheck disable=SC2086
  run ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/time-revamped" "$@"
}

tool_path() {
  printf "'%s'" "${REVAMPED_TESTS_DIR}/../bin/time-revamped"
}

bin_path() {
  printf "'%s'" "${REVAMPED_TESTS_DIR%/test}/bin/time-revamped"
}

has_line() {
  local line
  for line in "${lines[@]}"; do
    [[ "${line}" == "$1" ]] && return 0
  done
  return 1
}

answers() {
  export REVAMPED_TEST_GUM_ANSWERS="${BATS_TEST_TMPDIR}/answers"
  printf '%s\n' "$@" >"${REVAMPED_TEST_GUM_ANSWERS}"
}

eventually() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    /bin/sleep "${delay}"
  done
  "$@"
}

file_is() {
  local content
  content=$(cat "$1")
  [[ "${content}" == "$2" ]]
}

holds() {
  local now
  now=$(held "$1")
  [[ "${now}" == "$2" ]]
}
