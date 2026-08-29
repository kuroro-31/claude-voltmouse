#!/bin/bash
# voltmouse — pixel-art renderer.
# A 7x6 pixel grid is drawn in 3 terminal rows using the half-block ▀
# (foreground = upper pixel, background = lower pixel).
#
# Palette letters used in the grids below:
#   Y yellow body   K dark (ears / eyes)   R red cheeks
#   W white (charged ears)                 . transparent

VM_Y=${VM_Y:-'255;203;5'}
VM_K=${VM_K:-'45;45;45'}
VM_R=${VM_R:-'232;72;72'}
VM_W=${VM_W:-'255;250;220'}

vm_color() {
  case "$1" in
    Y) printf '%s' "$VM_Y" ;;
    K) printf '%s' "$VM_K" ;;
    R) printf '%s' "$VM_R" ;;
    W) printf '%s' "$VM_W" ;;
    *) printf '-' ;;
  esac
}

# $1=mood -> prints 6 grid rows
vm_grid() {
  case "$1" in
    happy)
      printf '%s\n' 'K.....K' 'KY...YK' '.YKYKY.' 'YYYYYYY' 'YRYYYRY' '.YYYYY.' ;;
    tired)
      printf '%s\n' 'K.....K' 'KY...YK' '.YKYKY.' 'YKYYYKY' 'YRYYYRY' '.YYYYY.' ;;
    zap)
      printf '%s\n' 'W.....W' 'WY...YW' '.YYYYY.' 'YKYYYKY' 'YRYYYRY' '.YYYYY.' ;;
    sleep)
      printf '%s\n' 'K.....K' 'KY...YK' '.YYYYY.' 'YKKYKKY' 'YRYYYRY' '.YYYYY.' ;;
    *)
      printf '%s\n' 'K.....K' 'KY...YK' '.YYYYY.' 'YKYYYKY' 'YRYYYRY' '.YYYYY.' ;;
  esac
}

# $1=upper letter $2=lower letter
vm_px() {
  local u l
  u=$(vm_color "$1"); l=$(vm_color "$2")
  if [ "$u" = "-" ] && [ "$l" = "-" ]; then printf ' '
  elif [ "$u" = "-" ]; then printf '\033[48;2;%sm \033[0m' "$l"
  elif [ "$l" = "-" ]; then printf '\033[38;2;%sm▀\033[0m' "$u"
  else printf '\033[38;2;%sm\033[48;2;%sm▀\033[0m' "$u" "$l"
  fi
}

# $1=mood $2=row index (1..3) -> prints one terminal row
vm_row() {
  # bash 3.2 (macOS system bash) has no mapfile, so read the grid line by line.
  local mood=$1 row=$2 line upper lower i n=0
  while IFS= read -r line; do
    n=$(( n + 1 ))
    [ "$n" -eq $(( (row - 1) * 2 + 1 )) ] && upper=$line
    [ "$n" -eq $(( (row - 1) * 2 + 2 )) ] && lower=$line
  done < <(vm_grid "$mood")
  for (( i = 0; i < ${#upper}; i++ )); do
    vm_px "${upper:i:1}" "${lower:i:1}"
  done
}

# $1=mood -> prints the whole 3-row sprite
vm_sprite() {
  local mood=$1 r
  for r in 1 2 3; do vm_row "$mood" "$r"; printf '\n'; done
}
