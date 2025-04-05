#!/bin/bash

# This looks like an initial attempt to find all of the labels used in Spectrum 128K.

cd "$(dirname "${0}")"

for ROM in 0 1; do
  cat "../zxspectrum_roms/Spectrum128K_ROM${ROM}.asm" | sed 's/;.*//' | sed '/^ *$/d' > "rom${ROM}"
  cat "rom${ROM}" | grep 'JP' | sort -u
  cat "rom${ROM}" | grep 'JR' | sort -u
  cat "rom${ROM}" | grep 'CALL' | sort -u
  cat "rom${ROM}" | grep 'DJNZ' | sort -u
  cat "rom${ROM}" | grep 'RET' | sort -u
  rm "rom${ROM}"
done
