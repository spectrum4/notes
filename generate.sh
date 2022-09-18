#!/bin/bash

head -c $((11 * 128)) /dev/urandom | hexdump -v -e '11/1 "0x%02x " "\n"' | while read a b c d e f g h i j k; do
  x="$(($RANDOM % 3))"
  if [ "${x}" -eq 0 ]; then
    y="$((RANDOM % 8))"
  else
    y=$((x + 7))
  fi
  l="$(printf '0x%02x' $y)"
  m="0x1$(($RANDOM % 2))"
  echo "$a $b $c $m $l $d $e $f $g $h $i $j $k"
done
