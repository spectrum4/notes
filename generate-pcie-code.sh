#!/bin/bash

cd "$(dirname "${0}")"

oldtimestamp=0
cat dmesg.log.2 | grep '\(Read\|Write\)' | grep '/pci/' | sed 's/^\[ *\([0-9]*\)\.\([0-9]*\)\]\(.*\)\[\([^ ]*\)\]=\(.*\)/\1\2 \3 \4 \5/' | while read timestamp b rw n bits vaddr val; do
  if [ $oldtimestamp == 0 ]; then
    oldtimestamp=$timestamp
  fi
  addr=$((vaddr + 0x30f3b90000))
  x10=$((0xfffffff0fd500000))
   x4=$((0xfffffff0fd504000))
  x13=$((0xfffffff0fd508000))
  x14=$((0xfffffff0fd509000))

  base=none
  if [ $((addr -x4)) -ge 0 ] && [ $((addr - x4)) -lt 8192 ]; then
    base=x4
    offset=$((addr - x4))
  fi
  if [ $((addr -x10)) -ge 0 ] && [ $((addr - x10)) -lt 8192 ]; then
    base=x10
    offset=$((addr - x10))
  fi
  if [ $((addr -x13)) -ge 0 ] && [ $((addr - x13)) -lt 8192 ]; then
    base=x13
    offset=$((addr - x13))
  fi
  if [ $((addr -x14)) -ge 0 ] && [ $((addr - x14)) -lt 8192 ]; then
    base=x14
    offset=$((addr - x14))
  fi

  if [ "${base}" == "none" ]; then
    printf "offset too big for 0x%x\n" "${addr}"
    exit 4
  fi

  case "${n}" in
    8)
      suffix="b"
      reg="w"
      ;;
    16)
      suffix="h"
      reg="w"
      ;;
    32)
      suffix="w"
      reg="w"
      ;;
    *)
      echo "Unknown bits: ${rw}"
      exit 2
      ;;
  esac

  echo
  delay=$((timestamp-oldtimestamp))
  if [ $delay -ge 100 ]; then
    echo "ldr x0, =${delay}"
    echo "bl  wait_usec"
  fi

  case "${rw}" in
    Read)
      printf "ldr${suffix}i ${reg}1, ${base}, #0x%x\n" "${offset}"
      ;;
    Write)
      echo "ldr x1, =${val}"
      printf "str${suffix}i ${reg}1, ${base}, #0x%x\n" "${offset}"
      ;;
    *)
      echo "Unknown read/write: ${rw}"
      exit 3
      ;;
  esac
  oldtimestamp=$timestamp
done
