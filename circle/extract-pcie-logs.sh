#!/bin/bash

# It looks like this converts circle logs and spectrum4 logs to a consistent
# format so that MMIO read/writes can be compared directly using `vim -d`.

cd "$(dirname "${0}")"

cat circle.log | grep '\(read\|write\)' | sed 's/\r//g' | sed 's/\[/[0x/' | sed 's/ = /=0x00000000000000000000/' \
   	| sed -E 's/(.*read)32(.*)=0x0*(.{8})$/\1\2=0x\3/' \
   	| sed -E 's/(.*write)32(.*)=0x0*(.{8})$/\1\2=0x\3/' \
   	| sed -E 's/(.*read)16(.*)=0x0*(.{4})$/\1\2=0x\3/' \
   	| sed -E 's/(.*write)16(.*)=0x0*(.{4})$/\1\2=0x\3/' \
   	| sed -E 's/(.*read)8(.*)=0x0*(.{2})$/\1\2=0x\3/' \
   	| sed -E 's/(.*write)8(.*)=0x0*(.{2})$/\1\2=0x\3/' \
	| sed 's/.*read/read/' | sed 's/.*write/write/' > circle_pcie.log

cat ../screenlog.0 | sed 's/\r//g' | sed 's/\[0xfffffff/[0x0000000/' | sed -n -E '/^(read|write)/p' | sed 's/\[0x00000000/[0x/' > spectrum4_pcie.log
cat circle_pcie.log  | grep -vF '[0xfd5' | grep -vF '[0xfe' | more | sed 's/\[0x\(...\]\)/[0x600000\1/g' | sed 's/\[0x\(..\]\)/[0x6000000\1/g' | sed 's/\[0x\(.\]\)/[0x60000000\1/g' > circle_xhci.log
cat spectrum4_pcie.log | sed 's/\[0x00000006/[0x6/g' | grep '\[0x60000....\]' > spectrum4_xhci.log

for file in circle_xhci.log spectrum4_xhci.log; do
  cat "${file}" > x
  cat x \
    | sed 's/.*\[0x600000002\].*/& XHCI_REG_CAP_HCIVERSION/' \
    | sed 's/.*\[0x600000020\].*/& USBCMD/' \
    | sed 's/.*\[0x600000024\].*/& USBSTS/' \
	| sed 's/.*\[0x600000038\].*/& CRCR (lo)/' \
	| sed 's/.*\[0x60000003c\].*/& CRCR (hi)/' \
    | sed 's/.*\[0x600000050\].*/& XHCI_REG_OP_DCBAAP_LO/' \
    | sed 's/.*\[0x600000054\].*/& XHCI_REG_OP_DCBAAP_HI/' \
    | sed 's/.*\[0x600000058\].*/& XHCI_REG_OP_CONFIG/' \
    | sed 's/.*\[0x600000100\].*/& host controller doorbell/' \
    | sed 's/.*\[0x600000220\].*/& IMAN/' \
    | sed 's/.*\[0x600000224\].*/& IMOD/' \
    | sed 's/.*\[0x600000228\].*/& ERSTSZ/' \
	| sed 's/.*\[0x600000230\].*/& ERSTBA (lo)/' \
	| sed 's/.*\[0x600000234\].*/& ERSTBA (hi)/' \
	| sed 's/.*\[0x600000238\].*/& ERDP (lo)/' \
	| sed 's/.*\[0x60000023c\].*/& ERDP (hi)/' \
	| sed 's/.*\[0x600000420\].*/& PORTSC (port 1)/' \
      > "${file}"
  rm x
done

vim -d spectrum4_xhci.log circle_xhci.log
vim -d spectrum4_pcie.log circle_pcie.log
