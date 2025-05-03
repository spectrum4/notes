#!/bin/bash

# This takes serial logging output from Spectrum +4 and extracts memory dumps
# of PCI configuration space, and converts it to the format used by lspci, so
# that lspci can decode it and provide textual description of the PCI
# configuration state.

function dump {
  basegrep="${1}"
  c=0
  echo -n 0
  cat screenlog.0 | grep "^ ${basegrep}" | while read a b; do
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
  cat linux-hex.txt | grep '00:00.0'
  dump 0fd500
  cat linux-hex.txt | grep '01:00.0'
  dump 0fd508
} > spectrum4-hex.txt
docker run --privileged -v $(pwd):/notes -w /notes -t --rm ubuntu /bin/bash -c 'apt-get update -y && apt-get upgrade -y && apt-get install -y pciutils && lspci -vvv -F spectrum4-hex.txt 2>/dev/null > spectrum4-decoded.txt && lspci -vvv -F linux-hex.txt 2>/dev/null > linux-decoded.txt && echo "All done"'
vim -d linux-decoded.txt spectrum4-decoded.txt
vim -d linux-hex.txt spectrum4-hex.txt
