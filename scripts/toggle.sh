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
      jq '{statusLine: (.statusLine // null)}' "$settings" > "$backup"
    fi
    tmp=$(mktemp)
    jq --arg cmd "bash \"$here/statusline.sh\"" \
       '.statusLine = {type: "command", command: $cmd, padding: 0}' \
       "$settings" > "$tmp" && mv "$tmp" "$settings"
    echo "voltmouse: status line enabled"
    ;;
  off)
    tmp=$(mktemp)
    if [ -f "$backup" ] && [ "$(jq -r '.statusLine' "$backup")" != "null" ]; then
      jq --slurpfile b "$backup" '.statusLine = $b[0].statusLine' "$settings" > "$tmp"
    else
      jq 'del(.statusLine)' "$settings" > "$tmp"
    fi
    mv "$tmp" "$settings"
    rm -f "$backup"
    echo "voltmouse: status line restored"
    ;;
  *) echo "usage: toggle.sh [on|off]" >&2; exit 2 ;;
esac
