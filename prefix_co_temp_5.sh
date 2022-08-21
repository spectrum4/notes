#!/bin/bash -eu

head -c 512 /dev/urandom | hexdump -v -e '"" 4/1 "0x%02x " "\n"' | sed 's/ $//' | while read a1 a2 a3 a4; do
  d=$((RANDOM % 3))
  if [ $d -eq 2 ]; then
    d=8
  fi
  a=$((RANDOM % 2))
  a=$((a+12))
  echo ${a1} ${a2} ${a3} 0x${a} 0x0${d} ${a4} 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
done
