#!/bin/bash

cd "$(dirname "${0}")"

cat circle.log | grep pcie | sed 's/\r//g' | sed 's/\[/[0x/' | sed 's/ = /=0x00000000000000000000/' \
   	| sed -E 's/(.*read)32(.*)=0x0*(.{8})$/\1\2=0x\3/' \
   	| sed -E 's/(.*write)32(.*)=0x0*(.{8})$/\1\2=0x\3/' \
   	| sed -E 's/(.*read)16(.*)=0x0*(.{4})$/\1\2=0x\3/' \
   	| sed -E 's/(.*write)16(.*)=0x0*(.{4})$/\1\2=0x\3/' \
   	| sed -E 's/(.*read)8(.*)=0x0*(.{2})$/\1\2=0x\3/' \
   	| sed -E 's/(.*write)8(.*)=0x0*(.{2})$/\1\2=0x\3/' \
	| sed 's/.*read/read/' | sed 's/.*write/write/' > circle_pcie.log

cat spectrum4.log | sed -n -E '/^(read|write)/p' | sed 's/\[0x00000000/[0x/' > spectrum4_pcie.log

vim -d spectrum4_pcie.log circle_pcie.log