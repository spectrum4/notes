Circle vs Spectrum4 XHCI / PCIe differences

Possible issues

1) Command TRB points to memory that is not in coherent region
2) Timing issue (spectrum4 not waiting somewhere)
3) Spectrum4 has enabled some power saving feature breaking stuff
4) Alignment issue
5) Error in command issued etc
6) Missing setup (e.g. of transfer ring)
7) Missing XHCI MMIO setup (e.g. during probe)

```
XHCI MSI vector status: 0x0000000000000001

read [0xfffffff0000053c0]=0xfffffff000223000    # internal dequeue pointer
read [0xfffffff0000053c8]=0x0000000100000000    # CSS bit in bit 32 (1)
read [0xfffffff000223000]=0x0000000001000000    # first two dwords of event TRB
read [0xfffffff000223008]=0x0000880101000000    # next two dwords of event TRB
Port Status Change Event (since bits 47:42 = 0b100010 = 34)
read [0xfffffff600000420]=0x400202e1            # PORTSC for port 1
write [0xfffffff600000420]=0x400202f1           # update PORTSC for port 1 (set bit 4 (port reset))
read [0xfffffff000223010]=0x0000000000000000    # read next TRB (first two dwords)
read [0xfffffff000223018]=0x0000000000000000    # (next two dwords) - not a pending TRB since PCS != CCS
write [0xfffffff600000238]=0x00223018           # update [ERDP_LO] = next TRB (clear EHB with RW1C in bit 3)
write [0xfffffff60000023c]=0x00000004           # update [ERDP_HI]
write [0xfffffff0000053c0]=0xfffffff000223010   # update internal event dequeue pointer

XHCI MSI vector status: 0x0000000000000001

read [0xfffffff0000053c0]=0xfffffff000223010    # internal dequeue pointer
read [0xfffffff0000053c8]=0x0000000100000000    # CSS bit in bit 32 (1)
read [0xfffffff000223010]=0x0000000001000000    # first two dwords of event TRB
read [0xfffffff000223018]=0x0000880101000000    # next two dwords of event TRB
Port Status Change Event                        # (since bits 47:42 = 0b100010 = 34)
read [0xfffffff600000420]=0x40200e03            # PORTSC for port 1
write [0xfffffff600000420]=0x40200e03           # update it - no change (not really necessary)
write [0xfffffff000220000]=0x0000000000000000   # first two dwords of command TRB (Enable Slot)
write [0xfffffff000220008]=0x00000000           # third dword
write [0xfffffff00022000c]=0x00002401           # fourth dword of Enable Slot TRB (type = 0b1001 << 10) with bit 0 set
write [0xfffffff600000100]=0x00000000           # ring host controller doorbell
read [0xfffffff000223020]=0x0000000400220000    # first two dwords of event TRB
read [0xfffffff000223028]=0x0100840101000000    # next two dwords of event TRB
Command Completion Event                        # (since bits 47:42 = 0b100001 = 33)
write [0xfffffff00021f008]=0x00224000           # update DCBAA[1] (lo) to a zero'd region for device context (since slot ID = 1)
write [0xfffffff00021f00c]=0x00000004           # update DCBAA[1] (hi) (same zero'd region)
write [0xfffffff000220010]=0x0000e000           # command TRB first dword: input context address for keyboard device (lo)
write [0xfffffff000220014]=0x00000004           # command TRB second dword: input context address for keyboard device (hi)
write [0xfffffff000220018]=0x00000000           # command TRB third dword
write [0xfffffff00022001c]=0x01002c01           # command TRB fourth dword - TRB type 11, BSR = 0, slot 1
write [0xfffffff600000100]=0x00000000           # ring host doorbell
read [0xfffffff000223030]=0x0000000000000000    # read next event TRB (first two dwords)
read [0xfffffff000223038]=0x0000000000000000    # read next two dwords of event TRB (PCS != CCS so not a pending event TRB)
write [0xfffffff600000238]=0x00223038           # update [ERDP_LO] = next TRB (clear EHB with RW1C in bit 3)
write [0xfffffff60000023c]=0x00000004           # update [ERDP_HI]
write [0xfffffff0000053c0]=0xfffffff000223030   # internal dequeue pointer
write [0xfffffff600000020]=0x00000005           # write XHCI_REG_OP_USBCMD
read [0xfffffff600000024]=0x00000018            # read XHCI_REG_OP_USBSTS

here is the data for the input context:

000e000 0000 0000 0003 0000 0000 0000 0000 0000
000e010 0000 0000 0000 0000 0000 0000 0000 0000
000e020 0000 0830 0000 0001 0000 0000 0000 0000
000e030 0000 0000 0000 0000 0000 0000 0000 0000
000e040 0000 0000 0026 0040 1001 0022 0004 0000
000e050 0008 0000 0000 0000 0000 0000 0000 0000
000e060 0000 0000 0000 0000 0000 0000 0000 0000
000e070 0000 0000 0000 0000 0000 0000 0000 0000
```

Circle logs:

```
00:00:02.58 xhcimmiospace: read32 [20] = 0
00:00:02.58 xhcimmiospace: write32 [20] = 4         # set USBCMD.INTE = 1
00:00:02.58 xhcimmiospace: read32 [20] = 4
00:00:02.59 xhcimmiospace: write32 [20] = 5         # set USBCMD.RUN_STOP = 1
00:00:02.59 xhci: IRQ
00:00:02.59 xhcimmiospace: read32 [24] = 18         # ???
00:00:02.59 xhcimmiospace: write32 [24] = 18        # ???
00:00:02.59 xhcimmiospace: read32 [220] = 3
00:00:02.59 xhcimmiospace: write32 [220] = 3        # update [interrupter 0 IMAN] setting InterruptEnable (bit 1) = 1

00:00:02.59 xhcimmiospace: read32 [420] = 400202e1
00:00:02.59 xhciroot: Port 1 status is 0x400202E1
00:00:02.59 xhcimmiospace: write32 [420] = 400202e1
00:00:02.59 xhcimmiospace: write32 [238] = 600898   # update ERDP_LO
00:00:02.59 xhcimmiospace: write32 [23c] = 4        # update ERDP_HI
00:00:02.96 xhcimmiospace: read32 [420] = 400002e1
00:00:02.97 xhcimmiospace: read32 [420] = 400002e1
00:00:02.97 xhcimmiospace: write32 [420] = 400002f1 # set bit 4 (Port Reset)
00:00:03.00 xhci: IRQ
00:00:03.00 xhcimmiospace: read32 [24] = 18         # ???
00:00:03.00 xhcimmiospace: write32 [24] = 18        # ???
00:00:03.00 xhcimmiospace: read32 [220] = 3
00:00:03.00 xhcimmiospace: write32 [220] = 3        # interrupter 0 IMAN
00:00:03.00 xhcimmiospace: read32 [420] = 40200e03  # Port Enabled, Port Speed, Link Polling State, Port Reset Change
00:00:03.00 xhciroot: Port 1 status is 0x40200E03
00:00:03.00 xhcimmiospace: write32 [420] = 40200e01
00:00:03.00 xhcimmiospace: write32 [238] = 6008a8
00:00:03.00 xhcimmiospace: write32 [23c] = 4
00:00:03.39 xhcimmiospace: read32 [420] = 40000e03  # Port Reset Change cleared
00:00:03.50 xhcimmiospace: read32 [420] = 40000e03
00:00:03.51 xhcicmd: Execute command 9 (control 0x2400)
00:00:03.51 xhcicommand: Dumping 0x10 bytes starting at 0x602100
00:00:03.52 xhcicommand: 2100: 00 00 00 00 00 00 00 00-00 00 00 00 01 24 00 00
00:00:03.52 xhcimmiospace: write32 [100] = 0
00:00:03.53 xhci: IRQ
00:00:03.53 xhcimmiospace: read32 [24] = 8
00:00:03.53 xhcimmiospace: write32 [24] = 8
00:00:03.53 xhcimmiospace: read32 [220] = 3
00:00:03.53 xhcimmiospace: write32 [220] = 3
00:00:03.53 xhcicmd: Command 9 completed with 1 (slot 1)
00:00:03.53 xhcimmiospace: write32 [238] = 6008b8
00:00:03.53 xhcimmiospace: write32 [23c] = 4
00:00:04.26 xhcicmd: Execute command 11 (control 0x1002C00)
00:00:04.27 xhcicommand: Dumping 0x10 bytes starting at 0x602110
00:00:04.28 xhcicommand: 2110: 00 A0 DE 00 04 00 00 00-00 00 00 00 01 2C 00 01
00:00:04.28 xhcimmiospace: write32 [100] = 0
00:00:04.29 xhci: IRQ
00:00:04.29 xhcimmiospace: read32 [24] = 8
00:00:04.29 xhcimmiospace: write32 [24] = 8
00:00:04.29 xhcimmiospace: read32 [220] = 3
00:00:04.29 xhcimmiospace: write32 [220] = 3
00:00:04.29 xhcicmd: Command 11 completed with 1 (slot 1)
00:00:04.29 xhcimmiospace: write32 [238] = 6008c8
00:00:04.29 xhcimmiospace: write32 [23c] = 4
00:00:04.60 xhcimmiospace: write32 [104] = 1
00:00:04.61 xhci: IRQ
00:00:04.61 xhcimmiospace: read32 [24] = 8
00:00:04.61 xhcimmiospace: write32 [24] = 8
00:00:04.61 xhcimmiospace: read32 [220] = 3
00:00:04.61 xhcimmiospace: write32 [220] = 3
```
