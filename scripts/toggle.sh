#!/bin/bash
# voltmouse — enable/disable the status line in the user's settings.json.
# Claude Code plugins cannot ship a status line directly, so we write the
# setting once and keep a backup of whatever was there before.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
settings="$HOME/.claude/settings.json"
backup="$HOME/.claude/settings.voltmouse-backup.json"
action=${1:-on}

command -v jq >/dev/null 2>&1 || { echo "voltmouse: jq is required" >&2; exit 1; }
[ -f "$settings" ] || echo '{}' > "$settings"

case "$action" in
  on)
    # Remember the previous statusLine (once) so `off` can restore it.
    if [ ! -f "$backup" ]; then
      jq '{statusLine: (.statusLine // null), spinnerVerbs: (.spinnerVerbs // null)}' \
        "$settings" > "$backup"
    fi
    tmp=$(mktemp)
    jq --arg cmd "bash \"$here/statusline.sh\"" \
       --slurpfile verbs "$here/../verbs.json" \
       '.statusLine = {type: "command", command: $cmd, padding: 0}
        | .spinnerVerbs = $verbs[0]' \
       "$settings" > "$tmp" && mv "$tmp" "$settings"
    echo "voltmouse: status line and spinner verbs enabled"
    ;;
  off)
    tmp=$(mktemp)
    if [ -f "$backup" ]; then
      jq --slurpfile b "$backup" '
        . as $s
        | (if $b[0].statusLine   == null then del(.statusLine)   else .statusLine   = $b[0].statusLine   end)
        | (if $b[0].spinnerVerbs == null then del(.spinnerVerbs) else .spinnerVerbs = $b[0].spinnerVerbs end)
      ' "$settings" > "$tmp"
    else
      jq 'del(.statusLine) | del(.spinnerVerbs)' "$settings" > "$tmp"
    fi
    mv "$tmp" "$settings"
    rm -f "$backup"
    echo "voltmouse: status line restored"
    ;;
  *) echo "usage: toggle.sh [on|off]" >&2; exit 2 ;;
esac
