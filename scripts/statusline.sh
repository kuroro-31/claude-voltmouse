#!/bin/bash
# voltmouse — Claude Code status line.
# Reads the status JSON from stdin and prints the mouse next to a compact
# summary: model/effort, context usage, rate limits, cwd and git branch.

set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=scripts/pixel.sh
. "$here/pixel.sh"

input=$(cat)

_jq() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

if command -v jq >/dev/null 2>&1; then
  model=$(_jq '.model.display_name // "?"')
  cwd=$(_jq '.cwd // empty')
  used=$(_jq '.context_window.used_percentage // empty')
  effort=$(_jq '.effort.level // empty')
  five=$(_jq '.rate_limits.five_hour.used_percentage // empty')
  week=$(_jq '.rate_limits.seven_day.used_percentage // empty')
else
  model="?"; cwd=$PWD; used=""; effort=""; five=""; week=""
fi
model=${model% (*}

basename=${cwd##*/}
[ -z "$basename" ] && basename=$cwd

branch=""; dirty=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ] && dirty="●"
fi

# --- mood ------------------------------------------------------------------
# The mouse reflects how much headroom is left: it charges up as the rate
# limit fills, and gets sleepy as the context window fills.
_num() { printf '%.0f' "${1:-0}" 2>/dev/null || printf '0'; }
mood=${VOLTMOUSE_MOOD:-}
if [ -z "$mood" ]; then
  ctx=$(_num "$used"); lim=$(_num "$five")
  if   [ "$ctx" -ge 90 ]; then mood=sleep
  elif [ "$ctx" -ge 70 ]; then mood=tired
  elif [ "$lim" -ge 80 ]; then mood=zap
  else mood=normal
  fi
fi

RESET=$'\033[0m'; BOLD=$'\033[1m'; DIM=$'\033[2m'
BODY=$'\033[38;2;255;203;5m'      # body yellow — model/effort
GRAY=$'\033[38;2;163;155;142m'    # structural — path, branch, separators, labels
AMBER=$'\033[38;2;199;158;99m'    # a metric that is filling up
RED=$'\033[38;2;232;72;72m'       # a metric close to its limit (cheek red)
SEP="${DIM}${GRAY} ▸ ${RESET}"

# A metric is grey until it matters: amber past 70%, red past 90%. The label
# stays dim so the number carries the colour.
_metric() { # $1=label $2=percentage
  local pct
  [ -z "${2:-}" ] && return
  pct=$(_num "$2")
  local c=$GRAY
  [ "$pct" -ge 70 ] && c=$AMBER
  [ "$pct" -ge 90 ] && c=$RED
  printf '%s%s%s %s%s%%%s' "$DIM$GRAY" "$1" "$RESET" "$c" "$pct" "$RESET"
}

line1="${BODY}⚡${RESET} ${BOLD}${BODY}${model}${RESET}"
[ -n "$effort" ] && line1+="${DIM}${BODY}/${RESET}${BOLD}${BODY}${effort}${RESET}"
[ -n "$used" ] && line1+="${SEP}$(_metric cx "$used")"
[ -n "$five" ] && line1+="${SEP}$(_metric 5h "$five")"
[ -n "$week" ] && line1+="${SEP}$(_metric 7d "$week")"

line2="${BOLD}${GRAY}${basename}${RESET}"
if [ -n "$branch" ]; then
  line2+="${SEP}${GRAY}⎇ ${branch}${RESET}"
  [ -n "$dirty" ] && line2+="${BOLD}${GRAY}${dirty}${RESET}"
fi

printf '%s  %s\n%s  %s\n%s' \
  "$(vm_row "$mood" 1)" "$line1" \
  "$(vm_row "$mood" 2)" "$line2" \
  "$(vm_row "$mood" 3)"
