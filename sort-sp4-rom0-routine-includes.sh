#!/bin/bash

cd /Users/pmoore/git/spectrum4/src/spectrum4/roms

for rom in 1; do
  cat ../../spectrum128k/roms/rom${rom}.symbols | sed -n 's/^ *[0-9]*: 0000\([0-9a-f]*\) *.* \([^ ]*\)$/\1 \2/p' | sort -u | while read addr routine; do
    addrupper="$(echo ${addr} | tr 'abcdef' 'ABCDEF')"
    if [ -f "${routine}.s" ]; then
      echo ".include \"${routine}.s\"    // L${addrupper}"
    fi
  done | grep -v '// L5' | ~/git/spectrum4/utils/asm-format/asm-format 
done

# cat ../../spectrum128k/roms/rom*.symbols | sed -n 's/^ *[0-9]*: 0000\([0-9a-f]*\) *.* \([^ ]*\)$/\1 \2/p' | sort -u | while read addr routine; do
#   addrupper="$(echo ${addr} | tr 'abcdef' 'ABCDEF')"
#   for file in *.s; do
#     cat "${file}" | sed "s/^${routine}:.*/${routine}:                \/\/ L${addrupper}/" > x
#     cat x > "${file}"
#   done
# done
# rm x
