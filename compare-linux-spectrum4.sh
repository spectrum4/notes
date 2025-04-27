#!/bin/bash

# This outputs spectrum4 and linux pcie logs in the same format so that they
# can be directly compared.

cd "$(dirname "${0}")"

base=$(cat dmesg.log | sed -n 's/.*Read 32 bits \[\(.*\)\]=0x00000000271114e4/\1/p' | sort -u)
offset=$((0xfffffff0fd500000 - base))
match=$(printf '%x\n' $base | sed 's/....$//')

cat dmesg.log | grep '\(Read\|Write\)' | grep -F "$match" | sed 's/^\[ *\([0-9]*\)\.\([0-9]*\)\]\(.*\)\[\([^ ]*\)\]=0x\(.*\)/\1\2 \3 \4 00000000\5/' | tr 'RW' 'rw' | while read timestamp rw n bits vaddr val; do
  addr=$((vaddr + offset))
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
done | uniq > linux.all

grep write linux.all | uniq > linux.writes
grep write screenlog.0 | grep 0xfffffff0fd50 | uniq > spectrum4.writes
vim -d linux.writes spectrum4.writes
grep 0xfffffff0fd50 screenlog.0 | uniq > spectrum4.all
vim -d linux.all spectrum4.all
