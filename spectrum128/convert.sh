#!/bin/bash

cd "$(dirname "${0}")"

for file in Spectrum128_ROM{0_BugFixed,1}; do

  {
    echo '################################'
    echo '# Created with convert.sh script'
    echo '################################'
    echo
	cat "${file}.asm" | sed 's/DEFB \$/.byte 0x/' | sed 's/DEFB /.byte /' | sed 's/DEFW /.word /' | sed 's/^;/#/' | sed 's/;/\/\//' | sed 's/DEFM /.ascii /' | sed 's/\$\([0-9a-fA-F\-]\)/0x\1/g'
  } > "${file}.s"
done

patch -p2 -i Spectrum128_ROM0_BugFixed.patch
