#!/bin/bash
# voltmouse — session-start greeting. Prints the mouse with a short line so the
# session opens with the mascot instead of a bare prompt.
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$here/pixel.sh"
mood=${VOLTMOUSE_MOOD:-normal}
name=${VOLTMOUSE_NAME:-voltmouse}
{
  printf '%s  \033[1m%s\033[0m\n' "$(vm_row "$mood" 1)" "$name"
  printf '%s  \033[2m%s\033[0m\n' "$(vm_row "$mood" 2)" "charged and ready"
  printf '%s\n' "$(vm_row "$mood" 3)"
} >&2
