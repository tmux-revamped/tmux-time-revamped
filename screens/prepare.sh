#!/bin/sh
set -eu

: "${SCREENS_REPO:?}"
demo=/Users/Shared/demo
rm -rf "${demo}"
mkdir -p "${demo}/home" "${demo}/bin" "${demo}/tmux-time-revamped"
cp -Rpf "${SCREENS_REPO}/bin" "${SCREENS_REPO}/lib" "${SCREENS_REPO}/time-revamped.tmux" "${demo}/tmux-time-revamped/"
for tool in tmux gum; do
  tool_path=$(command -v "${tool}")
  ln -s "${tool_path}" "${demo}/bin/${tool}"
done

cat >"${demo}/bin/date" <<'DATE'
#!/bin/sh
case "${1:-}" in
-d | -r) exec /bin/date "$@" ;;
*) ;;
esac
if [ -f /Users/Shared/demo/now ]; then
  read -r now </Users/Shared/demo/now
  exec /bin/date -r "${now}" "$@"
fi
exec /bin/date "$@"
DATE

cat >"${demo}/bin/cal" <<'CAL'
#!/bin/sh
exec /usr/bin/cal 10 2026
CAL

cat >"${demo}/bin/pbcopy" <<'CLIPBOARD'
#!/bin/sh
cat >/Users/Shared/demo/clipboard
CLIPBOARD

cat >"${demo}/bin/curl" <<'CURL'
#!/bin/sh
printf 'Lisbon\n'
CURL

chmod +x "${demo}/bin/date" "${demo}/bin/cal" "${demo}/bin/pbcopy" "${demo}/bin/curl"
printf '1792161000\n' >"${demo}/now"
