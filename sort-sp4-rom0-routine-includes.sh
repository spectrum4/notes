#!/bin/bash

# It looks like this attempts to reproduce the correct order for including rom
# routines in spectrum4 to match spectrum 128k. Presumably so that it is
# easier to compare and contrast them.

cd /Users/pmoore/git/spectrum4/src/spectrum4/roms

for rom in 0 1; do
  echo
  echo
  cat ../../spectrum128k/roms/rom${rom}.symbols | sed -n 's/^ *[0-9]*: 0000\([0-9a-f]*\) *.* \([^ ]*\)$/\1 \2/p' | sort -u | while read addr routine; do
    addrupper="$(echo ${addr} | tr 'abcdef' 'ABCDEF')"
    if [ -f "${routine}.s" ]; then
      echo ".include \"${routine}.s\"    // L${addrupper}"
    fi
  done | grep -v '// L5' | ~/git/spectrum4/utils/asm-format/asm-format 
done

exit 0

cat ../../spectrum128k/roms/rom*.symbols | sed -n 's/^ *[0-9]*: 0000\([0-9a-f]*\) *.* \([^ ]*\)$/\1 \2/p' | sort -u | while read addr routine; do
  addrupper="$(echo ${addr} | tr 'abcdef' 'ABCDEF')"
  for file in *.s; do
    cat "${file}" | sed "s/^${routine}:.*/${routine}:                \/\/ L${addrupper}/" > x
    cat x > "${file}"
  done
done
rm x
