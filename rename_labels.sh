#!/bin/bash

# It looks like this lints ZX Spectrum 128K disassembly (rom1.s) somehow. It
# also seems to do something with the labels (L25B7: ....) but I don't remember
# what. I wrote it too long ago and have forgotten the state.

cd ~/git/spectrum4

cat src/spectrum128k/roms/rom1.s | grep -n '^;;[A-Za-z0-9 \/\*-]*' | while read a b c; do
  line=$(echo $a | sed 's/:.*//')
  # echo $line
  n=$(echo $b | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-/*' 'abcdefghijklmnopqrstuvwxyz___')
  echo $n
# echo $line
# echo sed -n "$line,\$s/^\(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]\):.*/\1/p"
  cat src/spectrum128k/roms/rom1.s | sed -n "$line,\$s/^\(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]\):.*/\1/p" | head -1
  echo
done
