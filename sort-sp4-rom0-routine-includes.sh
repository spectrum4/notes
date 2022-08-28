#!/bin/bash

cd /Users/pmoore/git/spectrum4/src/spectrum4/roms
cat ../../spectrum128k/roms/rom0.symbols | sed -n 's/^ *[0-9]*: 0000\([0-9a-f]*\) *.* \([^ ]*\)$/\1 \2/p' | sort -u | while read addr routine; do addrupper="$(echo ${addr} | tr 'abcdef' 'ABCDEF')"; if [ -f "${routine}.s" ]; then echo ".include \"${routine}.s\"    // L${addrupper}"; fi; done | grep -v '// L5' | ~/git/spectrum4/utils/asm-format/asm-format 
