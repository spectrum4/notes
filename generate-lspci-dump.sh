#!/bin/bash

function dump {
  basegrep="${1}"
  c=0
  echo -n 0
  cat screenlog.0.linux-emulate-spectrum4 | grep "^ ${basegrep}" | while read a b; do
    echo "${b}" | sed 's/^\(...............................................\) /\1 \n/' | sed 's/\r//' | sed 's/  *$//' | while read line; do
      printf "%x: " $c
      c=$((c+16))
      echo "$line"
    done
    c=$((c+32))
  done
  echo
  return
}

cd "$(dirname "${0}")"

{
  echo '00:00.0 PCI bridge: Broadcom Inc. and subsidiaries BCM2711 PCIe Bridge (rev 20)'
  dump 0fd500
  echo '01:00.0 USB controller: VIA Technologies, Inc. VL805 USB 3.0 Host Controller (rev 01)'
  dump 0fd508
} > linux-emulate-spectrum4-hex.txt
