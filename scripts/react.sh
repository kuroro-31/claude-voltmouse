#!/bin/bash
# voltmouse — reaction on Stop / Notification. Keeps it to a single line so it
# never pushes the transcript around.
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$here/pixel.sh"
event=${1:-stop}
case "$event" in
  notification) mood=zap;  msg=${VOLTMOUSE_MSG_NOTIFICATION:-"needs you"} ;;
  *)            mood=happy; msg=${VOLTMOUSE_MSG_STOP:-"done"} ;;
esac
printf '%s  \033[2m%s\033[0m\n' "$(vm_row "$mood" 3)" "$msg" >&2
