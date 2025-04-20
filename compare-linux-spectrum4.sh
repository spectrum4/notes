#!/bin/bash

# This outputs spectrum4 and linux pcie logs in the same format so that they
# can be directly compared.

cd "$(dirname "${0}")"

cat dmesg.log | grep '\(Read\|Write\)' | grep 0xffffffc08224 | sed 's/^\[ *\([0-9]*\)\.\([0-9]*\)\]\(.*\)\[\([^ ]*\)\]=0x\(.*\)/\1\2 \3 \4 00000000\5/' | tr 'RW' 'rw' | while read timestamp rw n bits vaddr val; do
  addr=$((vaddr + 0x307b2c0000))
  case "${n}" in
    8)
      printf "${rw} [0x%x]=0x${val: -2}\n" "${addr}"
      ;;
    16)
      printf "${rw} [0x%x]=0x${val: -4}\n" "${addr}"
      ;;
    32)
      printf "${rw} [0x%x]=0x${val: -8}\n" "${addr}"
      ;;
    *)
      echo "Unknown bits: ${rw}"
      exit 3
      ;;
  esac
done > linux.all

grep write linux.all > linux.writes
grep write screenlog.0 | grep 0xfffffff0fd50 > spectrum4.writes
vim -d linux.writes spectrum4.writes
grep 0xfffffff0fd50 screenlog.0 > spectrum4.all
vim -d linux.all spectrum4.all
