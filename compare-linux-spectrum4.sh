#!/bin/bash

cd "$(dirname "${0}")"

cat dmesg.log.2 | grep '\(Read\|Write\)' | grep '/pci/' | sed 's/^\[ *\([0-9]*\)\.\([0-9]*\)\]\(.*\)\[\([^ ]*\)\]=0x\(.*\)/\1\2 \3 \4 00000000\5/' | tr 'RW' 'rw' | while read timestamp b rw n bits vaddr val; do
  addr=$((vaddr + 0x30f3b90000))
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
done > linux

vim -d screenlog.0.new-firmware-full linux
