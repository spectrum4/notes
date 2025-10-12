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

```
00:00:04.60 xhciep: Enqueue TRB control 0x30840 status 0x8 param1 0x1000680 param2 0x80000
00:00:04.61 xhciep: TRB enqueued:
00:00:04.61 xhciep: Dumping 0x10 bytes starting at 0x622880
00:00:04.62 xhciep: 2880: 80 06 00 01 00 00 08 00-08 00 00 00 41 08 03 00
00:00:04.62 xhciep: Enqueue TRB control 0x10c00 status 0x8 param1 0xde9280 param2 0x4
00:00:04.63 xhciep: TRB enqueued:
00:00:04.64 xhciep: Dumping 0x10 bytes starting at 0x622890
00:00:04.64 xhciep: 2890: 80 92 DE 00 04 00 00 00-08 00 00 00 01 0C 01 00
00:00:04.65 xhciep: Enqueue TRB control 0x1020 status 0x0 param1 0x0 param2 0x0
00:00:04.65 xhciep: TRB enqueued:
00:00:04.66 xhciep: Dumping 0x10 bytes starting at 0x6228A0
00:00:04.66 xhciep: 28A0: 00 00 00 00 00 00 00 00-00 00 00 00 21 10 00 00
00:00:04.67 xhcimmiospace: write32 [104] = 1
00:00:04.67 interruptgic: read32 [ff84200c] = af
00:00:04.67 xhci: IRQ
00:00:04.67 xhcimmiospace: read32 [24] = 8
00:00:04.67 xhcimmiospace: write32 [24] = 8
00:00:04.67 xhcimmiospace: read32 [220] = 3
00:00:04.67 xhcimmiospace: write32 [220] = 3
00:00:04.67 xhciep: Transfer event on endpoint 1 (completion 1, length 0)
00:00:04.67 xhcimmiospace: write32 [238] = 6008d8
00:00:04.67 xhcimmiospace: write32 [23c] = 4


SETUP STAGE
xHCI spec page 468

0x01000680 0b0000000100000000 00000110 10000000
    wValue 0x100 (256) => Descriptor Type 1 (DEVICE - page 251) and Descriptor Index 0.
      The descriptor index is used to select a specific descriptor (only for configuration and
      string descriptors) when several descriptors of the same type are implemented in a device. For example, a
      device can implement several configuration descriptors. For other standard descriptors that can be retrieved
      via a GetDescriptor() request, a descriptor index of zero must be used. The range of values used for a
      descriptor index is from 0 to one less than the number of descriptors of that type implemented by the device.
    bRequest 0x6 => GET_DESCRIPTOR (page 251 and sectio 9.4.3 on page 253)
    bmRequestType 128 (0x80) => device to host, standard type, device recipient (page 248)

0x00080000 0b0000000000001000 0000000000000000
    wLength = 8 => descriptor length 8 bytes (duplicate of TRB transfer length in DATA STAGE?)
    wIndex = 0 => Zero or Language ID

0x00000008 0b0000000000 00000 00000000000001000
    interruptor target = 0
    TRB Transfer Length = 8. Always 8 according to xHCI page 469.

0x00030841 0b00000000000000 11 000010 000 1 0 0000 1
    TRT (Transfer Type) = 3 (IN data stage) (p469 xHCI)
    TRB Type = 2 (Setup Stage) (p511 xHCI)
    IDT = 1 (required for setup stage - p469 xHCI)
    IOC = 0 (interrupt on completion not enabled - not sure why)
    C = 1 => cycle bit 1


DATA STAGE
xHCI spec page 470

0x00000004
    DMA address of data buffer (hi)

0x00de9280
    DMA address of data buffer (lo)

0x00000008 0b0000000000 00000 00000000000001000
    interruptor target = 0
    TD size = 0. The spec is very complicated here, and I don't understand it. xHCI spec page 218.
    TRB transfer length = 8 bytes. Looks like the host is free to set this to preferred value? p470.

0x00010c01 0b000000000000000 1 000011 000 0 0 0 0 0 0 1
    DIR = 1. IN direction. p471.
    TRB Type = 3 (Data stage) (p511)
    IDT = 0 (immediate data: false, i.e. data is referenced via pointer)
    IOC = 0 (no interrupt on completion)
    CH = 0 (end of chain, i.e. DATA STAGE is a single TRB)
    NS = 0 (no snoop - don't understand - see https://linux-usb.vger.kernel.narkive.com/2ODz0UCV/why-use-pci-express-no-snoop-option-for-xhci)
    ISP = 0 (interrupt on short packet disabled)
    ENT = 0 (evaluate next TRB disabled - see page 250, also not allowed since chain bit = 0)
    C = 1 (cycle bit)


STATUS STAGE
xHCI spec page 472

0x00000000
    RsvdZ

0x00000000
    RsvdZ

0x00000000 0b0000000000 0000000000000000000000
    Interruptor target = 0
    RsvdZ

0x00001021 0b000000000000000 0 000100 0000 1 0 00 0 1
    RsvdZ
    DIR = 0
    TRB Type = 4 (Status Stage) (p511)
    RsvdZ
    IOC = 1
    CH = 0
    RsvdZ
    ENT = 0
    C = 1
```
