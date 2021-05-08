#!/bin/bash

cd "$(dirname "${0}")"

cat src/spectrum128k/rom1.s | grep -n '^;;[A-Za-z0-9 \/\*-]*' | while read a b c; do
  line=$(echo $a | sed 's/:.*//')
  # echo $line
  n=$(echo $b | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-/*' 'abcdefghijklmnopqrstuvwxyz___')
  echo $n
# echo $line
# echo sed -n "$line,\$s/^\(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]\):.*/\1/p"
  cat src/spectrum128k/rom1.s | sed -n "$line,\$s/^\(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]\):.*/\1/p" | head -1
  echo
done
