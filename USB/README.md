1. [USB 2.0 Specification](https://www.usb.org/document-library/usb-20-specification-released-april-27-2000)
2. [Rene Stange - Circle USB Keyboard](https://github.com/rsta2/circle/tree/master/sample/08-usbkeyboard)
3. [Rene Stange - USPi Keyboard (32 and 64 bit)](https://github.com/rsta2/uspi#building)
4. [Leon de Boer - USB keyboard support RPi 3B 64 bit](https://github.com/LdB-ECM/Raspberry-Pi/tree/master/Arm32_64_USB/DiskImg)
5. [USB Stack in RISC OS 5](https://www.riscosopen.org/wiki/documentation/show/RISC%20OS%205%20USB%20stack%20overview)
6. [DWC Driver in RISC OS 5](https://github.com/winfreddy88/RISCOS5/tree/master/mixed/RiscOS/Sources/HWSupport/USB/Controllers/DWCDriver)
7. [USB Driver in RISC OS 5](https://github.com/winfreddy88/RISCOS5/tree/master/mixed/RiscOS/Sources/HWSupport/USB/USBDriver)
8. [USB Driver in Linux](https://github.com/torvalds/linux/tree/master/drivers/usb/dwc2)
9. [Broadcom ARM64 Linux USB drivers](https://github.com/Broadcom/arm64-linux/tree/master/drivers/usb)
10. [Craig Peacock - USB in a NutShell; Making sense of the USB standard](https://www.beyondlogic.org/usbnutshell/usb1.shtml)
11. [boochow - RPi 2 port of CSUD](https://github.com/Chadderz121/csud/compare/master...boochow:rpi2)
12. [Leon de Boer - explanation of why DMA address needs altering in CSUD for RPi2/3](https://www.raspberrypi.org/forums/viewtopic.php?f=72&t=16547&start=25#p1402806)
13. [Embedded Xinu](https://embedded-xinu.readthedocs.io/en/latest/index.html)
14. [FreeBSD DesignWare On-The-Go Controller](https://github.com/freebsd/freebsd/blob/master/sys/dev/usb/controller/dwc_otg.c)
15. [NetBSD DesignWare On-The-Go Controller](https://github.com/NetBSD/src/tree/trunk/sys/external/bsd/dwc2)
16. [Synopsis DesignWare On-The-Go Controller](https://www.synopsys.com/dw/ipdir.php?ds=dwc_usb_2_0_hs_otg)
17. [dwc_otg_hcd_linux.c](https://www.cl.cam.ac.uk/~atm26/ephemeral/rpi/dwc_otg/doc/html/dwc__otg__hcd__linux_8c-source.html)
18. [CSUD](https://github.com/Chadderz121/csud)
19. [Getting video stream from USB web-camera on Arduino Due](https://www.codeproject.com/Articles/863938/Getting-video-stream-from-USB-web-camera-on-Arduin)
20. [Implementing a USB Driver - RPi Bare Metal Forum](https://www.raspberrypi.org/forums/viewtopic.php?f=72&t=27695)
21. [Microchip - LAN9514 - Documents](https://www.microchip.com/wwwproducts/en/LAN9514)
22. [Microchip - LAN9514 - Data Sheet](http://ww1.microchip.com/downloads/en/devicedoc/00002306a.pdf)
23. [Microchip - LAN9514 Linux Driver](https://www.microchip.com/SWLibraryWeb/product.aspx?product=SRC-LAN95xx-LINUX)
24. [Linux smsc95xx.c driver](https://github.com/torvalds/linux/blob/master/drivers/net/usb/smsc95xx.c)
25. [Linux USB API](https://01.org/linuxgraphics/gfx-docs/drm/driver-api/usb/index.html)
26. [Ben Eater - How does a USB keyboard work?](https://www.youtube.com/watch?v=wdgULBpRoXk)
27. [Where can I Download USB3 VL805-Q6 Datasheet ?](https://forums.raspberrypi.com/viewtopic.php?t=302700)
28. [Reverse engineering a USB device with Rust - Harry Gill](https://gill.net.in/posts/reverse-engineering-a-usb-device-with-rust/)
29. [The Linux-USB Host Side API — The Linux Kernel documentation](https://www.kernel.org/doc/html/v4.10/driver-api/usb.html)
30. [u-boot PCIe implementation](https://github.com/u-boot/u-boot/blob/fbfa15c0b82b4e1ee1e974e2a85075cead502976/drivers/pci/pcie_brcmstb.c#L424-L573)


```
https://forums.raspberrypi.com/viewtopic.php?t=255322
https://wiki.osdev.org/PCI
https://wiki.osdev.org/PCI_Express
https://wiki.osdev.org/XHCI
https://github.com/haiku/haiku/blob/master/src/add-ons/kernel/busses/usb/xhci.cpp
https://github.com/torvalds/linux/blob/master/drivers/usb/host/xhci.c
https://github.com/u-boot/u-boot/blob/master/drivers/usb/host/xhci.c
https://github.com/vianpl/u-boot
https://forums.raspberrypi.com/viewtopic.php?p=1675084&hilit=pcie#p1675084 <- PCIe enumeration example
```


# PCIe

Linux starting point: https://github.com/torvalds/linux/blob/602fb860945fd6dce7989fcd3727d5fe4282f785/drivers/pci/controller/pcie-brcmstb.c#L865



pcie regs = Address 0xfd500000 (size 0x9310)

matches: https://github.com/torvalds/linux/blob/b23024676a2f135dbde2221481e2f4af616d0445/arch/arm/boot/dts/bcm2711.dtsi#L555-L587

in low peripheral mode, main peripherals are at 0x00000000fc000000
suggesting low peripherals + 0x01500000

=> 0x47c000000 + 0x01500000 = 0x47d500000 (for full 35-bit address map)


Steps from enumeration example above:
```
* set bits 0 and 1 of 32 bit register [0xfd509210] (reset controller)
* sleep for 1 millisecond
* clear bit 1 of 32 bit register [0xfd509210]
* read back value
* read 32 bit register [0xfd50406c] (REVISION)
* write 0xffffffff to 32 bit register [0xfd504314] (clear interrupts)
* write 0xffffffff to 32 bit register [0xfd504310] (mask interrupts)
* clear bit 0 of 32 bit register [0xfd509210] (bring controller out of reset)
* read 32 bit status register [0xfd504068] every 1ms, up to 100ms, until bits 4 and 5 are set
* report link not ready failure, if bits 4 and 5 are not set, and log value of register
* report PCIe not in RC mode, if bit 7 is not set, and log value of register
* log PCIe link is ready
* read [0xfd50043c] and change bits 0-23 to 0x060400 (pcie-pcie bridge) if not already set
* write [0xfd50400c]=0xf8000000 (lower 32 bits - PCI PCIE address)
* write [0xfd504010]=0x0 (upper 32 bits - PCI PCIE address)
* write [0xfd504070]=0x03f00000
* write [0xfd504080]=0x6
* write [0xfd504084]=0x6
```




## Steps from linux kernel

* [set](https://github.com/petemoore/linux/blob/rpi-5.15.y-debug-pcie-usb/drivers/pci/controller/pcie-brcmstb.c#L737) bit 1 (RGR1_SW_INIT_1_INIT_GENERIC_MASK) of register [0xfd509210] (RGR1_SW_INIT_1)
* set bit 0 (PCIE_RGR1_SW_INIT_1_PERST_MASK) of register [0xfd509210] (RGR1_SW_INIT_1)
* sleep for 100-200 microseconds
* clear bit 1 of [0xfd509210] (RGR1_SW_INIT_1)
* sleep for 100-200 microseconds
* clear bit 27 of [0xfd504204] (PCIE_MISC_HARD_PCIE_HARD_DEBUG)
* sleep for 100-200 microseconds
* set bits 12, 13 and clear bits 20, 21 of [0xfd504008] (PCIE_MISC_MISC_CTRL)
* set [0xfd504034]=0x11 (PCIE_MISC_RC_BAR2_CONFIG_LO)
* set [0xfd504038]=0x4 (PCIE_MISC_RC_BAR2_CONFIG_HI)
* set bits 27-31 of [0xfd504008] to 0b10001 (PCIE_MISC_MISC_CTRL)
* clear bits 0-4 of [0xfd50402c] (disable the PCIe->GISB memory window (PCIE_MISC_RC_BAR1_CONFIG_LO))
* clear bits 0-4 of [0xfd50403c] (disable the PCIe->SCB memory window (PCIE_MISC_RC_BAR3_CONFIG_LO))
* clear bit 0 of [0xfd509210] (RGR1_SW_INIT_1)
* wait for bits 4 and 5 of [0xfd504068] to be set, checking every 5000 us
* report PCIe not in RC mode, if bit 7 is not set, and error
* set [0xfd50400c]=0xc0000000 (lower 32 bits of pcie address as seen by pci controller?)
* set [0xfd504010]=0x0 (upper 32 bits of pcie address as seen by pci controller?)
* clear bits 30-31, set bits 20-29, clear bits 4-15 of [0xfd504070]
* update bit 0-7 of [0xfd504080] to 0x06
* update bit 0-7 of [0xfd504084] to 0x06
* set bits 10, 11 (already set) of [0xfd5004dc] (priv1 link capability)
* set bits 0-23 of [0xfd50043c] to 0x060400 (pcie-pcie bridge) - were already set
* Enable SSC (spread spectrum clocking) steps
  * set [0xfd501100]=0x1f (SET_ADDR_OFFSET to be written)
  * read it back ([0xfd501100])
  * set [0xfd501104]=0x80001100 (value to set, with bit 31 set)
  * read it back every 10us until bit 31 is clear or 10 attempts fail
  * set [0xfd501100]=0x100002 (SSC_CNTL_OFFSET to be read)
  * read it back ([0xfd501100])
  * SSC_CNTL_OFFSET = read [0xfd501108] every 10us until bit 31 is set or 10 attempts failed
  * set bits 14, 15 of SSC_CNTL_OFFSET (although bit 15 was already set)
  * set [0xfd501100]=0x2 (SSC_CNTL_OFFSET to be written)
  * read it back ([0xfd501100])
  * write SSC_CNTL_OFFSET to [0xfd501104]
  * read it back every 10us until bit 31 is clear or 10 attempts fail
  * set [0xfd501100]=0x100001 (SSC_STATUS_OFFSET to be read)
  * read it back ([0xfd501100])
  * SSC_STATUS_OFFSET = read [0xfd501108] every 10us until bit 31 is set or 10 attempts failed
* read 16 bits of [0xfd5000be]
* report pcie current link speed (bits 0-3) and negotiated link width (bits 4-9) (number of lanes?) and whether SSC enabled (from SSC_STATUS_OFFSET??)
* clear bits 2, 3 of [0xfd500188] (PCIe->SCB endian mode for BAR) (although already clear)
* clear bit 21 and set bit 1 of [0xfd504204] (refclk from RC gated with CLKREQ# input when ASPM L0s,L1 is enabled)
* get revision from [0xfd50406c]
* MSI init stuff
  * set [0xfd504514]=0xffffffff (mask interrupts?)
  * set [0xfd504508]=0xffffffff (clear interrupts?)
  * set [0xfd504044]=0xfffffffd (lower 32 bits of msi target address with bit 0 set => msi enable)
  * set [0xfd504048]=0x0 (upper 32 bits of msi target address)
  * set [0xfd50404c]=0xffe06540


## RC BAR 2 stuff

* https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L915-L925
* https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L780-L865

[ranges](https://devicetree-specification.readthedocs.io/en/latest/chapter2-devicetree-basics.html#ranges) and [dma-ranges](https://devicetree-specification.readthedocs.io/en/latest/chapter2-devicetree-basics.html#dma-ranges)
explains the meaning of the entries in [bcm2711.dtsi](https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/arch/arm/boot/dts/bcm2711.dtsi#L588-L596):

> The `dma-ranges` property is used to describe the direct memory access (DMA)
> structure of a memory-mapped bus whose devicetree parent can be accessed from
> DMA operations originating from the bus. It provides a means of defining a
> mapping or translation between the physical address space of the bus and the
> physical address space of the parent of the bus.
>
> The format of the value of the `dma-ranges` property is an arbitrary number
> of triplets of (`child-bus-address`, `parent-bus-address`, `length`). Each
> triplet specified describes a contiguous DMA address range.
>
> * The `child-bus-address` is a physical address within the child bus' address
>   space. The number of cells to represent the address depends on the bus and
>   can be determined from the `#address-cells` of this node (the node in which
>   the `dma-ranges` property appears).
> * The `parent-bus-address` is a physical address within the parent bus'
>   address space. The number of cells to represent the parent address is bus
>   dependent and can be determined from the `#address-cells` property of the
>   node that defines the parent's address space.
> * The `length` specifies the size of the range in the child’s address space.
>   The number of cells to represent the size can be determined from the
>   `#size-cells` of this node (the node in which the `dma-ranges` property
>   appears).

```
    scb {
        #address-cells = <2>;

        pcie0: pcie@7d500000 {
            #address-cells = <3>;
            #size-cells = <2>;
            ranges = <0x02000000 0x0 0xc0000000 0x6 0x00000000 0x0 0x40000000>;
            /*
             * The wrapper around the PCIe block has a bug
             * preventing it from accessing beyond the first 3GB of
             * memory.
             */
            dma-ranges = <0x02000000 0x0 0x00000000 0x0 0x00000000 0x0 0xc0000000>;
        }
    }
```

From this we see that one range (CPU address -> PCI address):

* child bus address: 0x02000000 0x0 0xc0000000
* parent bus address: 0x6 0x00000000
* length: 0x0 0x40000000

and one DMA range (PCI address -> CPU address) is defined:

* child bus address: 0x02000000 0x0 0x00000000
* parent bus address: 0x0 0x00000000
* length: 0x0 0xc0000000

To understand this better, see:

* [PCI Address Translation](https://elinux.org/Device_Tree_Usage#PCI_Address_Translation)
* [PCI Bus Binding to Open Firmware](https://www.openfirmware.info/data/docs/bus.pci.pdf)

## ranges

One 1GB 32 bit non-prefetchable memory space region mapping is defined:
* CPU physical addresses [0x0000 0006 0000 0000 -> 0x0000 0006 3fff ffff]
maps to:
* PCI addresses [0x0000 0000 c000 0000 -> 0x0000 0000 ffff ffff]

## dma ranges

One 3GB 32 bit non-prefetchable memory space region mapping is defined:
* PCI addresses [0x0000 0000 0000 0000 -> 0x0000 0000 bfff ffff]
maps to:
* CPU physical addresses [0x0000 0000 0000 0000 -> 0x0000 0000 bfff ffff]

Reverse engineering from dmesg logs, where [0xfd504034] (PCIE_MISC_RC_BAR2_CONFIG_LO) = 0x11
and [0xfd504038] (PCIE_MISC_RC_BAR2_CONFIG_HI) = 0x4 and looking at code
[here](https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L915-L925)
we can deduce what rci bar2 offset and size must be:

```
rc2 bar2 offset:   0bhhhh hhhh hhhh hhhh hhhh hhhh hhhh hhhh llll llll llll llll llll llll llll llll
rc2 bar2 size:     0bHHHH HHHH HHHH HHHH HHHH HHHH HHHH HHHH LLLL LLLL LLLL LLLL LLLL LLLL LLLL LLLL
tmp:               0b0000 0000 0000 0000 0000 0000 0000 0000 llll llll llll llll llll llll llll llll
tmp:               0b0000 0000 0000 0000 0000 0000 0000 0000 llll llll llll llll llll llll lllx xxxx

LO: 0b0000 0000 0000 0000 0000 0000 0001 0001 = 0bllll llll llll llll llll llll lllx xxxx

HI: 0b0000 0000 0000 0000 0000 0000 0000 0100 = 0bhhhh hhhh hhhh hhhh hhhh hhhh hhhh hhhh

=> rc bar2 offset = 0x4 0000 0000
and brcm_pcie_encode_ibar_size(size) = 0x11
=> log2_in = 32
=> rc bar2 size = 4GB = 0x1 0000 0000
```

## Steps from dmesg debug logs

```
[    1.204465] brcm-pcie fd500000.pcie: host bridge /scb/pcie@7d500000 ranges:
[    1.204503] brcm-pcie fd500000.pcie:   No bus range found for /scb/pcie@7d500000, using [bus 00-ff]
[    1.204586] brcm-pcie fd500000.pcie:      MEM 0x0600000000..0x063fffffff -> 0x00c0000000
[    1.204666] brcm-pcie fd500000.pcie:   IB MEM 0x0000000000..0x00ffffffff -> 0x0400000000
[    1.204768] brcm-pcie fd500000.pcie: pdev->name: fd500000.pcie
[    1.204781] brcm-pcie fd500000.pcie: pdev->id: 0xffffffff
[    1.204794] brcm-pcie fd500000.pcie: pdev->id_auto: false
[    1.204806] brcm-pcie fd500000.pcie: pdev->dev.init_name: (null)
[    1.204819] brcm-pcie fd500000.pcie: pdev->dev.platform_data: 0x0000000000000000
[    1.204833] brcm-pcie fd500000.pcie: pdev->platform_dma_mask: 0x00000000ffffffff
[    1.204846] brcm-pcie fd500000.pcie: pdev->num_resources: 0x3
[    1.204858] brcm-pcie fd500000.pcie: pdev->driver_override: (null)
[    1.204870] drivers/pci/controller/pcie-brcmstb.c:735 Read 32 bits [0xfd509210]=0x1
[    1.204883] drivers/pci/controller/pcie-brcmstb.c:737 Write 32 bits [0xfd509210]=0x3 // set bit 1
[    1.204896] drivers/pci/controller/pcie-brcmstb.c:775 Read 32 bits [0xfd509210]=0x3
[    1.204909] drivers/pci/controller/pcie-brcmstb.c:777 Write 32 bits [0xfd509210]=0x3 // set bit 0
sleep 100-200 us
[    1.205154] drivers/pci/controller/pcie-brcmstb.c:735 Read 32 bits [0xfd509210]=0x3
[    1.205169] drivers/pci/controller/pcie-brcmstb.c:737 Write 32 bits [0xfd509210]=0x1 // clear bit 1
[    1.205182] drivers/pci/controller/pcie-brcmstb.c:890 Read 32 bits [0xfd504204]=0x200000
[    1.205194] drivers/pci/controller/pcie-brcmstb.c:892 Write 32 bits [0xfd504204]=0x200000 // clear bit 27 (disable hardware debug?)
sleep 100-200 us
[    1.205452] drivers/pci/controller/pcie-brcmstb.c:909 Read 32 bits [0xfd504008]=0x0
[    1.205467] drivers/pci/controller/pcie-brcmstb.c:913 Write 32 bits [0xfd504008]=0x3000 // set bits 12, 13 and clear bits 20, 21

[    1.205483] drivers/pci/controller/pcie-brcmstb.c:923 Write 32 bits [0xfd504034]=0x11 // explicitly set RC_BAR2_CONFIG_LO
[    1.205495] drivers/pci/controller/pcie-brcmstb.c:924 Write 32 bits [0xfd504038]=0x4 // explicity set RC_BAR2_CONFIG_HI

[    1.205507] drivers/pci/controller/pcie-brcmstb.c:927 Read 32 bits [0xfd504008]=0x3000
[    1.205519] drivers/pci/controller/pcie-brcmstb.c:938 Write 32 bits [0xfd504008]=0x88003000 // set bits 27-31 to 0b10001

[    1.205530] drivers/pci/controller/pcie-brcmstb.c:953 Read 32 bits [0xfd50402c]=0x0
[    1.205541] drivers/pci/controller/pcie-brcmstb.c:955 Write 32 bits [0xfd50402c]=0x0 // clear bits 0-4 (disable the PCIe->GISB memory window (RC_BAR1))
[    1.205553] drivers/pci/controller/pcie-brcmstb.c:958 Read 32 bits [0xfd50403c]=0x0
[    1.205564] drivers/pci/controller/pcie-brcmstb.c:960 Write 32 bits [0xfd50403c]=0x0 // clear bits 0-4 (disable the PCIe->SCB memory window (RC_BAR3))
[    1.205576] drivers/pci/controller/pcie-brcmstb.c:775 Read 32 bits [0xfd509210]=0x1
[    1.205587] drivers/pci/controller/pcie-brcmstb.c:777 Write 32 bits [0xfd509210]=0x0 // clear bit 0

// sleeping a lot here! 5000 microsecond sleep between each attempt - wait for bits 4 and 5 to be set
[    1.205598] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.218357] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.234348] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.250347] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.266346] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0xb0

// check if link is down (this additional mmio read is a consequence of implementation)
[    1.266361] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0xb0

[    1.266374] drivers/pci/controller/pcie-brcmstb.c:693 Read 32 bits [0xfd504068]=0xb0 // check bit 7 is set, otherwise PCIe not in RC mode (error!)

[    1.266387] drivers/pci/controller/pcie-brcmstb.c:434 Write 32 bits [0xfd50400c]=0xc0000000 // lower 32 bits of pcie address
[    1.266398] drivers/pci/controller/pcie-brcmstb.c:435 Write 32 bits [0xfd504010]=0x0 // upper 32 bits of pcie address
[    1.266410] drivers/pci/controller/pcie-brcmstb.c:441 Read 32 bits [0xfd504070]=0x10
[    1.266421] drivers/pci/controller/pcie-brcmstb.c:446 Write 32 bits [0xfd504070]=0x3ff00000 // update mask 0xfff0fff0 with 0x3ff, 0x000
[    1.266433] drivers/pci/controller/pcie-brcmstb.c:453 Read 32 bits [0xfd504080]=0x0
[    1.266445] drivers/pci/controller/pcie-brcmstb.c:456 Write 32 bits [0xfd504080]=0x6 // update bits 0-7 to 0x06
[    1.266457] drivers/pci/controller/pcie-brcmstb.c:459 Read 32 bits [0xfd504084]=0x0
[    1.266468] drivers/pci/controller/pcie-brcmstb.c:462 Write 32 bits [0xfd504084]=0x6 // update bits 0-7 to 0x06
[    1.266483] drivers/pci/controller/pcie-brcmstb.c:1006 Read 32 bits [0xfd5004dc]=0x315e12 // priv1 link capability
[    1.266495] drivers/pci/controller/pcie-brcmstb.c:1009 Write 32 bits [0xfd5004dc]=0x315e12 // set bits 10, 11 (were already set)
[    1.266507] drivers/pci/controller/pcie-brcmstb.c:1015 Read 32 bits [0xfd50043c]=0x20060400
[    1.266519] drivers/pci/controller/pcie-brcmstb.c:1018 Write 32 bits [0xfd50043c]=0x20060400 // ensure bits 0-23 are 0x060400 (pcie-pcie bridge)

///////////////////////////////////////////////////////////////
//// Enable SSC (Spread Spectrum Clocking) ////////////////////
// write SET_ADDR_OFFSET (0x1f) = 0x1100
[    1.266531] drivers/pci/controller/pcie-brcmstb.c:358 Write 32 bits [0xfd501100]=0x1f // explicit update
[    1.266543] drivers/pci/controller/pcie-brcmstb.c:360 Read 32 bits [0xfd501100]=0x1f // just read it back - no idea why
[    1.266554] drivers/pci/controller/pcie-brcmstb.c:361 Write 32 bits [0xfd501104]=0x80001100 // explicit update
[    1.266567] drivers/pci/controller/pcie-brcmstb.c:363 Read 32 bits [0xfd501104]=0x80001100 // read it back every 10us until bit 31 is clear or 10 attempts failed
[    1.266589] drivers/pci/controller/pcie-brcmstb.c:366 Read 32 bits [0xfd501104]=0x1100 // bit 31 is now clear
// read SSC_CNTL_OFFSET (0x2)
[    1.266602] drivers/pci/controller/pcie-brcmstb.c:337 Write 32 bits [0xfd501100]=0x100002 // explicit update
[    1.266614] drivers/pci/controller/pcie-brcmstb.c:339 Read 32 bits [0xfd501100]=0x100002 // just read it back - no idea why
[    1.266625] drivers/pci/controller/pcie-brcmstb.c:341 Read 32 bits [0xfd501108]=0x8000803a // read every 10us until bit 31 is set or 10 attempts failed
//
// set bits 14, 15 => 0x8000c03a (although bit 15 was already set)
//
// update SSC_CNTL_OFFSET (0x2)
[    1.266637] drivers/pci/controller/pcie-brcmstb.c:358 Write 32 bits [0xfd501100]=0x2 // explicit update
[    1.266649] drivers/pci/controller/pcie-brcmstb.c:360 Read 32 bits [0xfd501100]=0x2 // just read it back - no idea why
[    1.266660] drivers/pci/controller/pcie-brcmstb.c:361 Write 32 bits [0xfd501104]=0x8000c03a // value from above
[    1.266671] drivers/pci/controller/pcie-brcmstb.c:363 Read 32 bits [0xfd501104]=0x8000c03a // read it back every 10us until bit 31 is clear or 10 attempts failed
[    1.266695] drivers/pci/controller/pcie-brcmstb.c:366 Read 32 bits [0xfd501104]=0xc03a // bit 31 now clear
// read SSC_STATUS_OFFSET (0x1)
[    1.268728] drivers/pci/controller/pcie-brcmstb.c:337 Write 32 bits [0xfd501100]=0x100001 // explicit update
[    1.268742] drivers/pci/controller/pcie-brcmstb.c:339 Read 32 bits [0xfd501100]=0x100001 // just read if back - no idea why
[    1.268754] drivers/pci/controller/pcie-brcmstb.c:341 Read 32 bits [0xfd501108]=0x80001c17 // read every 10us until bit 31 is set or 10 attempts failed
//
///////////////////////////////////////////////////////////////

[    1.268766] drivers/pci/controller/pcie-brcmstb.c:1028 Read 16 bits [0xfd5000be]=0x9012 // bits 0-3 (0x2) current link speed, bits 4-9 (0x1) negotiated link width (number of lanes?)

[    1.268782] brcm-pcie fd500000.pcie: link up, 5.0 GT/s PCIe x1 (SSC) // "5.0 GT/s" is from current link speed, "x1" is from negotiated link width, "(SSC)" is from SSC setting success

[    1.268795] drivers/pci/controller/pcie-brcmstb.c:1036 Read 32 bits [0xfd500188]=0x0
[    1.268807] drivers/pci/controller/pcie-brcmstb.c:1039 Write 32 bits [0xfd500188]=0x0 // clear bits 2,3 (PCIe->SCB endian mode for BAR)
[    1.268818] drivers/pci/controller/pcie-brcmstb.c:1041 Read 32 bits [0xfd504204]=0x200000 // debug
[    1.268829] drivers/pci/controller/pcie-brcmstb.c:1060 Write 32 bits [0xfd504204]=0x2 // clear bit 21, set bit 1; Refclk from RC should be gated with CLKREQ# input when ASPM L0s,L1 is enabled => set CLKREQ_DEBUG_ENABLE field to 1

///////// pcie setup complete, continue with probe stuff

[    1.268840] drivers/pci/controller/pcie-brcmstb.c:1355 Read 32 bits [0xfd50406c]=0x304 // get revision

[    1.269055] drivers/pci/controller/pcie-brcmstb.c:627 Write 32 bits [0xfd504514]=0xffffffff // explicit - mask interrupts?
[    1.269071] drivers/pci/controller/pcie-brcmstb.c:628 Write 32 bits [0xfd504508]=0xffffffff // explicit - clear interrupts?
[    1.269082] drivers/pci/controller/pcie-brcmstb.c:634 Write 32 bits [0xfd504044]=0xfffffffd // lower 32 bits of msi target address | 0x01 (=> msi enable)
[    1.269094] drivers/pci/controller/pcie-brcmstb.c:636 Write 32 bits [0xfd504048]=0x0 // upper 32 bits of msi target address
[    1.269105] drivers/pci/controller/pcie-brcmstb.c:640 Write 32 bits [0xfd50404c]=0xffe06540 // explicit

[    1.269279] brcm-pcie fd500000.pcie: PCI host bridge to bus 0000:00
[    1.269297] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.269314] pci_bus 0000:00: root bus resource [mem 0x600000000-0x63fffffff] (bus address [0xc0000000-0xffffffff])

[    1.269333] drivers/pci/access.c:93 Read 32 bits [0xfd500000]=0x271114e4
[    1.269347] drivers/pci/access.c:89 Read 8 bits [0xfd50000e]=0x1
[    1.269360] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.269370] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.269380] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.269389] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.269399] drivers/pci/access.c:91 Read 16 bits [0xfd5000ae]=0x42
[    1.269409] drivers/pci/access.c:93 Read 32 bits [0xfd5000b0]=0x8002
[    1.269431] drivers/pci/access.c:93 Read 32 bits [0xfd500008]=0x6040020
[    1.269442] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.269453] drivers/pci/access.c:93 Read 32 bits [0xfd500000]=0x271114e4
[    1.269462] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.269472] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.269483] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.269492] drivers/pci/access.c:93 Read 32 bits [0xfd500184]=0x2800000
[    1.269501] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.269512] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e

[    1.269528] pci 0000:00:00.0: [14e4:2711] type 01 class 0x060400

[    1.269545] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x0
[    1.269555] drivers/pci/access.c:111 Write 16 bits [0xfd500004]=0x400
[    1.269565] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x400
[    1.269574] drivers/pci/access.c:111 Write 16 bits [0xfd500004]=0x0
[    1.269585] drivers/pci/access.c:89 Read 8 bits [0xfd50003d]=0x1
[    1.269594] drivers/pci/access.c:89 Read 8 bits [0xfd50003c]=0x0
[    1.269605] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x0
[    1.269614] drivers/pci/access.c:93 Read 32 bits [0xfd500010]=0x0
[    1.269623] drivers/pci/access.c:113 Write 32 bits [0xfd500010]=0xffffffff
[    1.269633] drivers/pci/access.c:93 Read 32 bits [0xfd500010]=0x0
[    1.269642] drivers/pci/access.c:113 Write 32 bits [0xfd500010]=0x0
[    1.269652] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x0
[    1.269662] drivers/pci/access.c:93 Read 32 bits [0xfd500014]=0x0
[    1.269670] drivers/pci/access.c:113 Write 32 bits [0xfd500014]=0xffffffff
[    1.269680] drivers/pci/access.c:93 Read 32 bits [0xfd500014]=0x0
[    1.269690] drivers/pci/access.c:113 Write 32 bits [0xfd500014]=0x0
[    1.269700] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x0
[    1.269709] drivers/pci/access.c:93 Read 32 bits [0xfd500038]=0x0
[    1.269717] drivers/pci/access.c:113 Write 32 bits [0xfd500038]=0xfffff800
[    1.269727] drivers/pci/access.c:93 Read 32 bits [0xfd500038]=0x0
[    1.269736] drivers/pci/access.c:113 Write 32 bits [0xfd500038]=0x0
[    1.269745] drivers/pci/access.c:91 Read 16 bits [0xfd50001c]=0x0
[    1.269754] drivers/pci/access.c:111 Write 16 bits [0xfd50001c]=0xe0f0
[    1.269765] drivers/pci/access.c:91 Read 16 bits [0xfd50001c]=0x0
[    1.269773] drivers/pci/access.c:111 Write 16 bits [0xfd50001c]=0x0
[    1.269783] drivers/pci/access.c:93 Read 32 bits [0xfd500024]=0x1fff1
[    1.269794] drivers/pci/access.c:93 Read 32 bits [0xfd500028]=0x0
[    1.269803] drivers/pci/access.c:113 Write 32 bits [0xfd500028]=0xffffffff
[    1.269812] drivers/pci/access.c:93 Read 32 bits [0xfd500028]=0xffffffff
[    1.269821] drivers/pci/access.c:113 Write 32 bits [0xfd500028]=0x0
[    1.269832] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.269842] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.269851] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.269860] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.269870] drivers/pci/access.c:93 Read 32 bits [0xfd5000b0]=0x8002
[    1.269880] drivers/pci/access.c:91 Read 16 bits [0xfd5000b4]=0x2c10
[    1.269891] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.269900] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.269909] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.269918] drivers/pci/access.c:93 Read 32 bits [0xfd5000d0]=0x8081f
[    1.269928] drivers/pci/access.c:93 Read 32 bits [0xfd5000d4]=0x0
[    1.269936] drivers/pci/access.c:91 Read 16 bits [0xfd5000d4]=0x0
[    1.269946] drivers/pci/access.c:111 Write 16 bits [0xfd5000d4]=0x400
[    1.269957] drivers/pci/access.c:91 Read 16 bits [0xfd50003e]=0x0
[    1.269966] drivers/pci/access.c:111 Write 16 bits [0xfd50003e]=0x2
[    1.269984] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.269993] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270003] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270012] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.270021] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270031] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270040] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270049] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.270061] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270070] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270079] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270088] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.270098] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270107] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270116] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270125] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.270136] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270145] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270154] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270163] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.270172] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.270181] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.270190] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.270199] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.270209] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.270218] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.270227] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.270238] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.270247] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.270256] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.270266] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.270275] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.270299] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270330] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270341] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270352] drivers/pci/access.c:91 Read 16 bits [0xfd50004a]=0x4813
[    1.270366] pci 0000:00:00.0: PME# supported from D0 D3hot
[    1.270382] drivers/pci/access.c:91 Read 16 bits [0xfd50004c]=0x2008
[    1.270392] drivers/pci/access.c:111 Write 16 bits [0xfd50004c]=0xa008
[    1.270403] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270412] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270421] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270431] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270441] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.270451] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.270461] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.270470] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.270484] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.270493] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.270503] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.270512] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.270522] drivers/pci/access.c:91 Read 16 bits [0xfd50004c]=0x2008
[    1.274184] drivers/pci/access.c:93 Read 32 bits [0xfd500018]=0x10100
[    1.274199] drivers/pci/access.c:91 Read 16 bits [0xfd50003e]=0x2
[    1.274209] drivers/pci/access.c:111 Write 16 bits [0xfd50003e]=0x2
[    1.274220] drivers/pci/access.c:91 Read 16 bits [0xfd5000ca]=0x1
[    1.274229] drivers/pci/access.c:91 Read 16 bits [0xfd5000c8]=0x0
[    1.274239] drivers/pci/access.c:111 Write 16 bits [0xfd5000c8]=0x10
[    1.274257] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.274268] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.274278] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.274287] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.274298] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.274336] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.274347] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.274357] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.274367] drivers/pci/access.c:91 Read 16 bits [0xfd500006]=0x10
[    1.274376] drivers/pci/access.c:89 Read 8 bits [0xfd500034]=0x48
[    1.274386] drivers/pci/access.c:91 Read 16 bits [0xfd500048]=0xac01
[    1.274395] drivers/pci/access.c:91 Read 16 bits [0xfd5000ac]=0x10
[    1.274405] drivers/pci/access.c:93 Read 32 bits [0xfd5000b8]=0x655c12
[    1.274417] drivers/pci/access.c:91 Read 16 bits [0xfd5000be]=0x9012
[    1.274524] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274563] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
Vendor ID + DeviceID
PCI configuration registers
Header Registers 0x00-0x3f
Vendor ID: 0x1106
Device ID: 0x3483
default: 0x34831106
=> Offset = 0xfd508000
[    1.274575] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274612] drivers/pci/access.c:89 Read 8 bits [0xfd50800e]=0x0
=> Header Type (HDTYPE) (offset 0x0e)
[    1.274621] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274658] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
=> "PCI Status" (default: 0x10)
[    1.274668] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274705] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.274714] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274750] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.274759] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274796] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.274805] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274843] drivers/pci/access.c:91 Read 16 bits [0xfd5080c4]=0x10
[    1.274852] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274888] drivers/pci/access.c:91 Read 16 bits [0xfd5080c6]=0x2
[    1.274897] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274933] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.274953] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.274991] drivers/pci/access.c:93 Read 32 bits [0xfd508008]=0xc033001
=> Revision ID + Class Code (default 0x0c033001
[    1.275000] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275037] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.275045] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275082] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
Vendor ID + DeviceID
default: 0x34831106
[    1.275091] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275127] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.275137] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275174] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.275186] pci 0000:01:00.0: [1106:3483] type 00 class 0x0c0330
[    1.275203] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275241] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
PCI Command
default: 0x0000
[    1.275250] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275259] drivers/pci/access.c:111 Write 16 bits [0xfd508004]=0x400
PCI Command
INTRDIS (Interrupt Disable) = 1
[    1.275297] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275337] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x400
read back written value
[    1.275347] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275354] drivers/pci/access.c:111 Write 16 bits [0xfd508004]=0x0
PCI Command
WRITE INTRDIS (Interrupt Disable) = 0
[    1.275394] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275434] drivers/pci/access.c:89 Read 8 bits [0xfd50803d]=0x1
[    1.275442] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275480] drivers/pci/access.c:89 Read 8 bits [0xfd50803c]=0x0
[    1.275489] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275525] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
PCI Command
READ INTRDIS (Interrupt Disable) = 0
[    1.275534] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275570] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0x4
[    1.275579] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275586] drivers/pci/access.c:113 Write 32 bits [0xfd508010]=0xffffffff
[    1.275624] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275664] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0xfffff004
[    1.275673] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275680] drivers/pci/access.c:113 Write 32 bits [0xfd508010]=0x4
[    1.275719] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275759] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0x0
[    1.275768] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275776] drivers/pci/access.c:113 Write 32 bits [0xfd508014]=0xffffffff
[    1.275814] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275855] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0xffffffff
[    1.275864] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275871] drivers/pci/access.c:113 Write 32 bits [0xfd508014]=0x0
[    1.275910] pci 0000:01:00.0: reg 0x10: [mem 0x00000000-0x00000fff 64bit]
[    1.275927] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.275964] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
[    1.275973] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276009] drivers/pci/access.c:93 Read 32 bits [0xfd508018]=0x0
[    1.276018] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276027] drivers/pci/access.c:113 Write 32 bits [0xfd508018]=0xffffffff
[    1.276064] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276105] drivers/pci/access.c:93 Read 32 bits [0xfd508018]=0x0
[    1.276113] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276121] drivers/pci/access.c:113 Write 32 bits [0xfd508018]=0x0
[    1.276159] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276199] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
[    1.276208] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276245] drivers/pci/access.c:93 Read 32 bits [0xfd50801c]=0x0
[    1.276254] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276261] drivers/pci/access.c:113 Write 32 bits [0xfd50801c]=0xffffffff
[    1.276299] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276339] drivers/pci/access.c:93 Read 32 bits [0xfd50801c]=0x0
[    1.276348] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276355] drivers/pci/access.c:113 Write 32 bits [0xfd50801c]=0x0
[    1.276393] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276433] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
[    1.276442] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276478] drivers/pci/access.c:93 Read 32 bits [0xfd508020]=0x0
[    1.276487] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276494] drivers/pci/access.c:113 Write 32 bits [0xfd508020]=0xffffffff
[    1.276533] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276573] drivers/pci/access.c:93 Read 32 bits [0xfd508020]=0x0
[    1.276582] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276589] drivers/pci/access.c:113 Write 32 bits [0xfd508020]=0x0
[    1.276627] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276667] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
[    1.276676] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276712] drivers/pci/access.c:93 Read 32 bits [0xfd508024]=0x0
[    1.276721] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276728] drivers/pci/access.c:113 Write 32 bits [0xfd508024]=0xffffffff
[    1.276766] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276806] drivers/pci/access.c:93 Read 32 bits [0xfd508024]=0x0
[    1.276816] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276823] drivers/pci/access.c:113 Write 32 bits [0xfd508024]=0x0
[    1.276861] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276901] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
[    1.276910] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276947] drivers/pci/access.c:93 Read 32 bits [0xfd508030]=0x0
[    1.276956] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.276963] drivers/pci/access.c:113 Write 32 bits [0xfd508030]=0xfffff800
[    1.277001] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277041] drivers/pci/access.c:93 Read 32 bits [0xfd508030]=0x0
[    1.277050] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277057] drivers/pci/access.c:113 Write 32 bits [0xfd508030]=0x0
[    1.277097] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277137] drivers/pci/access.c:91 Read 16 bits [0xfd50802c]=0x1106
[    1.277145] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277182] drivers/pci/access.c:91 Read 16 bits [0xfd50802e]=0x3483
[    1.277191] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277229] drivers/pci/access.c:91 Read 16 bits [0xfd5080cc]=0x2810
[    1.277238] drivers/pci/access.c:91 Read 16 bits [0xfd5000b4]=0x2c10
[    1.277247] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277284] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.277293] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277329] drivers/pci/access.c:91 Read 16 bits [0xfd5080cc]=0x2810
[    1.277339] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277377] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.277386] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277422] drivers/pci/access.c:93 Read 32 bits [0xfd5080e8]=0x12
[    1.277436] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277473] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.277483] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277519] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.277528] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277565] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.277573] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277610] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.277619] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277655] drivers/pci/access.c:91 Read 16 bits [0xfd5080c4]=0x10
[    1.277664] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277702] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.277711] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277747] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.277756] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277793] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.277802] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277838] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.277847] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277883] drivers/pci/access.c:91 Read 16 bits [0xfd508092]=0x84
[    1.277892] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277929] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.277937] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.277974] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.277983] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278019] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.278028] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278064] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.278075] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278111] drivers/pci/access.c:91 Read 16 bits [0xfd5080c4]=0x10
[    1.278120] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278157] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.278166] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278203] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.278212] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278250] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.278259] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278296] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.278322] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278360] drivers/pci/access.c:91 Read 16 bits [0xfd5080c4]=0x10
[    1.278369] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278406] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.278416] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278453] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.278461] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278498] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.278507] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278543] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.278552] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278589] drivers/pci/access.c:91 Read 16 bits [0xfd5080c4]=0x10
[    1.278598] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278635] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.278644] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278680] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.278689] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278726] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.278734] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278771] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.278792] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278829] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.278838] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278874] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.278883] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278919] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.278928] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.278965] drivers/pci/access.c:91 Read 16 bits [0xfd508082]=0x4803
[    1.278974] pci 0000:01:00.0: PME# supported from D0 D3hot
[    1.278989] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279026] drivers/pci/access.c:91 Read 16 bits [0xfd508084]=0x0
[    1.279036] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279043] drivers/pci/access.c:111 Write 16 bits [0xfd508084]=0x8000
[    1.279082] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279122] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.279131] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279169] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.279178] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279214] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.279223] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279259] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.279268] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279304] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.279313] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279349] drivers/pci/access.c:91 Read 16 bits [0xfd5080c4]=0x10
[    1.279359] drivers/pci/access.c:93 Read 32 bits [0xfd5000d0]=0x8081f
[    1.279368] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279404] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.279414] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279451] drivers/pci/access.c:93 Read 32 bits [0xfd5080f0]=0x0
[    1.279460] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279496] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.279506] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279542] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.279553] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279589] drivers/pci/access.c:91 Read 16 bits [0xfd5080d6]=0x1012
[    1.279598] drivers/pci/access.c:91 Read 16 bits [0xfd5000be]=0x9012
[    1.279608] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279644] drivers/pci/access.c:91 Read 16 bits [0xfd508006]=0x10
[    1.279653] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279690] drivers/pci/access.c:89 Read 8 bits [0xfd508034]=0x80
[    1.279698] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279735] drivers/pci/access.c:91 Read 16 bits [0xfd508080]=0x9001
[    1.279744] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279780] drivers/pci/access.c:91 Read 16 bits [0xfd508090]=0xc405
[    1.279789] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279825] drivers/pci/access.c:91 Read 16 bits [0xfd5080c4]=0x10
[    1.279834] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.279871] drivers/pci/access.c:91 Read 16 bits [0xfd508084]=0x0
[    1.280169] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.280208] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.280228] drivers/pci/access.c:93 Read 32 bits [0xfd5000b8]=0x655c12
[    1.280238] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.280275] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.280284] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.280320] drivers/pci/access.c:91 Read 16 bits [0xfd5080d6]=0x1012
[    1.280330] drivers/pci/access.c:91 Read 16 bits [0xfd5000be]=0x9012
[    1.280339] drivers/pci/access.c:91 Read 16 bits [0xfd5000bc]=0x0
[    1.280348] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.280385] drivers/pci/access.c:91 Read 16 bits [0xfd5080d4]=0x43
[    1.280394] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.280402] drivers/pci/access.c:111 Write 16 bits [0xfd5080d4]=0x43
[    1.280440] drivers/pci/access.c:91 Read 16 bits [0xfd5000bc]=0x0
[    1.280449] drivers/pci/access.c:111 Write 16 bits [0xfd5000bc]=0x40
[    1.280459] drivers/pci/access.c:91 Read 16 bits [0xfd5000bc]=0x40
[    1.280468] drivers/pci/access.c:111 Write 16 bits [0xfd5000bc]=0x60
[    1.280477] drivers/pci/access.c:91 Read 16 bits [0xfd5000be]=0x9812
[    1.290360] drivers/pci/access.c:91 Read 16 bits [0xfd5000be]=0xd012
[    1.290374] drivers/pci/access.c:93 Read 32 bits [0xfd5000b8]=0x64cc12
[    1.290383] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290419] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.290429] drivers/pci/access.c:91 Read 16 bits [0xfd5000bc]=0x40
[    1.290438] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290474] drivers/pci/access.c:91 Read 16 bits [0xfd5080d4]=0x43
[    1.290485] drivers/pci/access.c:93 Read 32 bits [0xfd500244]=0x28081f
[    1.290494] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290532] drivers/pci/access.c:93 Read 32 bits [0xfd508004]=0x100000
[    1.290541] drivers/pci/access.c:93 Read 32 bits [0xfd500248]=0x100
[    1.290550] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290587] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.290597] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290634] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.290643] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290679] drivers/pci/access.c:91 Read 16 bits [0xfd5080d4]=0x43
[    1.290689] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290725] drivers/pci/access.c:91 Read 16 bits [0xfd5080d4]=0x43
[    1.290734] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.290741] drivers/pci/access.c:111 Write 16 bits [0xfd5080d4]=0x40
[    1.290781] drivers/pci/access.c:91 Read 16 bits [0xfd5000bc]=0x40
[    1.290790] drivers/pci/access.c:111 Write 16 bits [0xfd5000bc]=0x40
[    1.294015] drivers/pci/access.c:111 Write 16 bits [0xfd50003e]=0x2
[    1.294029] drivers/pci/access.c:93 Read 32 bits [0xfd500018]=0x10100
[    1.294039] drivers/pci/access.c:91 Read 16 bits [0xfd50003e]=0x2
[    1.294048] drivers/pci/access.c:111 Write 16 bits [0xfd50003e]=0x2
[    1.294057] drivers/pci/access.c:91 Read 16 bits [0xfd5000ca]=0x1
[    1.294067] drivers/pci/access.c:91 Read 16 bits [0xfd5000c8]=0x10
[    1.294076] drivers/pci/access.c:111 Write 16 bits [0xfd5000c8]=0x10
[    1.294085] drivers/pci/access.c:111 Write 16 bits [0xfd50003e]=0x2
[    1.294115] pci 0000:00:00.0: BAR 8: assigned [mem 0x600000000-0x6000fffff]
[    1.294138] pci 0000:01:00.0: BAR 0: assigned [mem 0x600000000-0x600000fff 64bit]
[    1.294155] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.294164] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x0
[    1.294173] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.294180] drivers/pci/access.c:111 Write 16 bits [0xfd508004]=0x0
[    1.294190] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.294197] drivers/pci/access.c:113 Write 32 bits [0xfd508010]=0xc0000004
[    1.294207] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.294215] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0xc0000004
[    1.294224] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.294231] drivers/pci/access.c:113 Write 32 bits [0xfd508014]=0x0
[    1.294241] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.294250] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0x0
[    1.294259] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.294266] drivers/pci/access.c:111 Write 16 bits [0xfd508004]=0x0
[    1.294278] pci 0000:00:00.0: PCI bridge to [bus 01]
[    1.294293] drivers/pci/access.c:113 Write 32 bits [0xfd500030]=0xffff
[    1.294302] drivers/pci/access.c:111 Write 16 bits [0xfd50001c]=0xf0
[    1.294331] drivers/pci/access.c:113 Write 32 bits [0xfd500030]=0x0
[    1.294343] pci 0000:00:00.0:   bridge window [mem 0x600000000-0x6000fffff]
[    1.294358] drivers/pci/access.c:113 Write 32 bits [0xfd500020]=0xc000c000
[    1.294367] drivers/pci/access.c:113 Write 32 bits [0xfd50002c]=0x0
[    1.294377] drivers/pci/access.c:113 Write 32 bits [0xfd500024]=0xfff0
[    1.294387] drivers/pci/access.c:113 Write 32 bits [0xfd500028]=0x0
[    1.294396] drivers/pci/access.c:113 Write 32 bits [0xfd50002c]=0x0
[    1.294405] drivers/pci/access.c:111 Write 16 bits [0xfd50003e]=0x2
[    1.400003] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.400018] drivers/pci/access.c:89 Read 8 bits [0xfd50803d]=0x1
[    1.400057] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.400067] drivers/pci/access.c:89 Read 8 bits [0xfd50803d]=0x1
[    1.400200] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.400210] drivers/pci/access.c:109 Write 8 bits [0xfd50803c]=0x3e
[    1.450483] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.450525] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
[    1.450536] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.450573] drivers/pci/access.c:91 Read 16 bits [0xfd508084]=0x0
[    1.450584] drivers/pci/access.c:93 Read 32 bits [0xfd500000]=0x271114e4
[    1.450594] drivers/pci/access.c:91 Read 16 bits [0xfd50004c]=0x2008
[    1.450606] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x0
[    1.450617] pci 0000:00:00.0: enabling device (0000 -> 0002)
[    1.450634] drivers/pci/access.c:111 Write 16 bits [0xfd500004]=0x2
[    1.450646] drivers/pci/access.c:89 Read 8 bits [0xfd50003d]=0x1
[    1.450656] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x2
[    1.450666] drivers/pci/access.c:91 Read 16 bits [0xfd500004]=0x2
[    1.450676] drivers/pci/access.c:111 Write 16 bits [0xfd500004]=0x6
[    1.450686] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.450723] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x146
[    1.450733] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.450770] drivers/pci/access.c:89 Read 8 bits [0xfd50803d]=0x1
[    1.450779] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.450815] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x146
[    1.450895] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.450933] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x146
[    1.451010] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.451048] drivers/pci/access.c:89 Read 8 bits [0xfd508060]=0x30
[    1.451352] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.451390] drivers/pci/access.c:93 Read 32 bits [0xfd508050]=0x138a1
[    1.453316] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453326] drivers/pci/access.c:89 Read 8 bits [0xfd50800c]=0x0
[    1.453335] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453343] drivers/pci/access.c:109 Write 8 bits [0xfd50800c]=0x10
[    1.453381] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453420] drivers/pci/access.c:89 Read 8 bits [0xfd50800c]=0x10
[    1.453430] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453466] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x146
[    1.453475] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453482] drivers/pci/access.c:111 Write 16 bits [0xfd508004]=0x156
[    1.453527] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453564] drivers/pci/access.c:91 Read 16 bits [0xfd508092]=0x84
[    1.453573] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453609] drivers/pci/access.c:91 Read 16 bits [0xfd508092]=0x84
[    1.453618] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453625] drivers/pci/access.c:111 Write 16 bits [0xfd508092]=0x84
[    1.453664] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453702] drivers/pci/access.c:91 Read 16 bits [0xfd508092]=0x84
[    1.453798] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453838] drivers/pci/access.c:91 Read 16 bits [0xfd508092]=0x84
[    1.453847] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453854] drivers/pci/access.c:111 Write 16 bits [0xfd508092]=0x84
[    1.453893] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453900] drivers/pci/access.c:113 Write 32 bits [0xfd508094]=0xfffffffc
[    1.453938] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453945] drivers/pci/access.c:113 Write 32 bits [0xfd508098]=0x0
[    1.453983] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.453991] drivers/pci/access.c:111 Write 16 bits [0xfd50809c]=0x6540
[    1.454030] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.454069] drivers/pci/access.c:91 Read 16 bits [0xfd508092]=0x84
[    1.454090] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.454127] drivers/pci/access.c:91 Read 16 bits [0xfd508004]=0x146
[    1.454137] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.454144] drivers/pci/access.c:111 Write 16 bits [0xfd508004]=0x546
[    1.454182] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.454221] drivers/pci/access.c:91 Read 16 bits [0xfd508092]=0x84
[    1.454230] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.454237] drivers/pci/access.c:111 Write 16 bits [0xfd508092]=0x85
[    1.456574] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.456585] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.582618] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.582631] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.593392] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.593401] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.711023] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.711036] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.711511] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.711519] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.722035] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.722046] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.838770] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.838781] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.839148] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.839156] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.858722] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.858731] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.859109] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.859117] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.859659] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.859666] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.860073] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.860081] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.860527] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.860535] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.860965] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.860973] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.861393] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.861402] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.862395] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.862403] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.862707] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.862723] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.863503] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.863512] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.863834] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.863845] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.864419] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.864428] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.864788] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.864802] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.865127] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.865138] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.865780] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.865791] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.867545] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.867558] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.878716] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.878729] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.880716] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.880724] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.882602] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.882615] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.986583] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.986599] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.987015] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.987023] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.987369] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.987379] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.987730] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.987738] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.988082] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.988091] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.988437] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.988447] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.090674] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.090688] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.091076] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.091085] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.091333] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.091343] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.091903] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.091912] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.110575] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.110589] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.111022] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.111030] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.170565] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.170578] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.171702] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.171710] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.171952] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.171960] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.172222] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.172231] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.190598] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.190608] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.190989] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.190997] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.250676] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.250687] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.251184] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.251193] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.271717] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.271728] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.274717] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.274729] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.276592] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.276602] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.277217] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.277227] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.277467] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.277475] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.279843] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.279853] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.280092] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.280100] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.280968] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.280979] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.281218] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.281225] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.282234] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.282244] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.282585] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.282594] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.282955] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.282964] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.283718] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.283728] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.286219] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.286229] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.290220] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.290231] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.292010] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.292020] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.292320] input: PixArt Dell MS116 USB Optical Mouse as /devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.1/1-1.1:1.0/0003:413C:301A.0001/input/input0
[    2.293228] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.293236] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.293606] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.293616] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.293827] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.293837] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.294344] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.294354] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.314710] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.314725] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.315168] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.315177] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.374595] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.374609] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.380607] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.380616] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.380857] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.380865] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.381206] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.381216] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.398741] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.398761] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.399192] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.399203] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.458805] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.458831] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.459962] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.459989] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.484505] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.484533] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.491256] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.491274] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.510881] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.510919] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.515380] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.515396] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.515627] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.515636] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.534131] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.534146] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.534381] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.534391] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.538883] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.538893] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.539130] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.539139] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.540589] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.540604] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.540909] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.540918] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.541265] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.541275] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.541507] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.541515] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.542060] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.542071] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.545380] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.545389] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.548634] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.548652] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.568136] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.568175] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.570239] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.570247] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.570915] input:   Raspberry Pi Internal Keyboard as /devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04D9:0007.0002/input/input1
[    2.574885] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.574900] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.634150] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.634167] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.652152] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.652166] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.654956] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.654965] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.655234] input:   Raspberry Pi Internal Keyboard as /devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.1/0003:04D9:0007.0003/input/input2
[   24.059778] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.059831] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
[   24.059842] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.059879] drivers/pci/access.c:93 Read 32 bits [0xfd508004]=0x100546
[   24.059888] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.059925] drivers/pci/access.c:93 Read 32 bits [0xfd508008]=0xc033001
[   24.059934] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.059971] drivers/pci/access.c:93 Read 32 bits [0xfd50800c]=0x10
[   24.059981] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060017] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0xc0000004
[   24.060027] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060063] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0x0
[   24.060072] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060109] drivers/pci/access.c:93 Read 32 bits [0xfd508018]=0x0
[   24.060118] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060155] drivers/pci/access.c:93 Read 32 bits [0xfd50801c]=0x0
[   24.060164] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060200] drivers/pci/access.c:93 Read 32 bits [0xfd508020]=0x0
[   24.060211] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060248] drivers/pci/access.c:93 Read 32 bits [0xfd508024]=0x0
[   24.060257] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060293] drivers/pci/access.c:93 Read 32 bits [0xfd508028]=0x0
[   24.060303] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060339] drivers/pci/access.c:93 Read 32 bits [0xfd50802c]=0x34831106
[   24.060350] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060387] drivers/pci/access.c:93 Read 32 bits [0xfd508030]=0x0
[   24.060398] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060435] drivers/pci/access.c:93 Read 32 bits [0xfd508034]=0x80
[   24.060445] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060483] drivers/pci/access.c:93 Read 32 bits [0xfd508038]=0x0
[   24.060556] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.060594] drivers/pci/access.c:93 Read 32 bits [0xfd50803c]=0x13e
[   24.228915] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.228960] drivers/pci/access.c:93 Read 32 bits [0xfd508040]=0x0
[   24.228970] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229007] drivers/pci/access.c:93 Read 32 bits [0xfd508044]=0x100
[   24.229015] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229052] drivers/pci/access.c:93 Read 32 bits [0xfd508048]=0x419b7009
[   24.229060] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229096] drivers/pci/access.c:93 Read 32 bits [0xfd50804c]=0x4
[   24.229104] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229140] drivers/pci/access.c:93 Read 32 bits [0xfd508050]=0x138a1
[   24.229149] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229185] drivers/pci/access.c:93 Read 32 bits [0xfd508054]=0x0
[   24.229193] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229228] drivers/pci/access.c:93 Read 32 bits [0xfd508058]=0x0
[   24.229237] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229272] drivers/pci/access.c:93 Read 32 bits [0xfd50805c]=0x34831106
[   24.229281] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229317] drivers/pci/access.c:93 Read 32 bits [0xfd508060]=0x2030
[   24.229325] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229361] drivers/pci/access.c:93 Read 32 bits [0xfd508064]=0x0
[   24.229369] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229405] drivers/pci/access.c:93 Read 32 bits [0xfd508068]=0x0
[   24.229413] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229449] drivers/pci/access.c:93 Read 32 bits [0xfd50806c]=0x0
[   24.229457] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229493] drivers/pci/access.c:93 Read 32 bits [0xfd508070]=0x0
[   24.229501] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229537] drivers/pci/access.c:93 Read 32 bits [0xfd508074]=0x0
[   24.229545] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229581] drivers/pci/access.c:93 Read 32 bits [0xfd508078]=0x30008
[   24.229589] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229625] drivers/pci/access.c:93 Read 32 bits [0xfd50807c]=0x18000001
[   24.229633] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229669] drivers/pci/access.c:93 Read 32 bits [0xfd508080]=0x89c39001
[   24.229677] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229714] drivers/pci/access.c:93 Read 32 bits [0xfd508084]=0x0
[   24.229723] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229759] drivers/pci/access.c:93 Read 32 bits [0xfd508088]=0x0
[   24.229768] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229804] drivers/pci/access.c:93 Read 32 bits [0xfd50808c]=0x0
[   24.229812] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229848] drivers/pci/access.c:93 Read 32 bits [0xfd508090]=0x85c405
[   24.229857] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229894] drivers/pci/access.c:93 Read 32 bits [0xfd508094]=0xfffffffc
[   24.229902] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.229939] drivers/pci/access.c:93 Read 32 bits [0xfd508098]=0x0
[   24.232995] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233047] drivers/pci/access.c:93 Read 32 bits [0xfd50809c]=0x6540
[   24.233057] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233093] drivers/pci/access.c:93 Read 32 bits [0xfd5080a0]=0x0
[   24.233102] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233139] drivers/pci/access.c:93 Read 32 bits [0xfd5080a4]=0x0
[   24.233147] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233183] drivers/pci/access.c:93 Read 32 bits [0xfd5080a8]=0x0
[   24.233191] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233227] drivers/pci/access.c:93 Read 32 bits [0xfd5080ac]=0x0
[   24.233236] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233272] drivers/pci/access.c:93 Read 32 bits [0xfd5080b0]=0x0
[   24.233281] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233316] drivers/pci/access.c:93 Read 32 bits [0xfd5080b4]=0x0
[   24.233324] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233360] drivers/pci/access.c:93 Read 32 bits [0xfd5080b8]=0x0
[   24.233369] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233405] drivers/pci/access.c:93 Read 32 bits [0xfd5080bc]=0x0
[   24.233414] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233451] drivers/pci/access.c:93 Read 32 bits [0xfd5080c0]=0x2000
[   24.233459] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233495] drivers/pci/access.c:93 Read 32 bits [0xfd5080c4]=0x20010
[   24.233504] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233541] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[   24.233549] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233585] drivers/pci/access.c:93 Read 32 bits [0xfd5080cc]=0x192810
[   24.233593] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233629] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[   24.233637] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233673] drivers/pci/access.c:93 Read 32 bits [0xfd5080d4]=0x10120043
[   24.233681] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233717] drivers/pci/access.c:93 Read 32 bits [0xfd5080d8]=0x0
[   24.233725] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233761] drivers/pci/access.c:93 Read 32 bits [0xfd5080dc]=0x0
[   24.233774] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233816] drivers/pci/access.c:93 Read 32 bits [0xfd5080e0]=0x0
[   24.233828] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233863] drivers/pci/access.c:93 Read 32 bits [0xfd5080e4]=0x0
[   24.233872] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233907] drivers/pci/access.c:93 Read 32 bits [0xfd5080e8]=0x12
[   24.233915] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233951] drivers/pci/access.c:93 Read 32 bits [0xfd5080ec]=0x0
[   24.233959] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.233995] drivers/pci/access.c:93 Read 32 bits [0xfd5080f0]=0x0
[   24.234003] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.234039] drivers/pci/access.c:93 Read 32 bits [0xfd5080f4]=0x10022
[   24.234048] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.234085] drivers/pci/access.c:93 Read 32 bits [0xfd5080f8]=0x0
[   24.234093] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.234129] drivers/pci/access.c:93 Read 32 bits [0xfd5080fc]=0x0



```


```
PCIe revision: 0x0000000000000304
PCIe link is ready
PCIe status register: 0x00000000000000b0
PCIe loop iterations: 0x000000000000002e
PCIe class code (initial): 0x0000000020060400
PCIe class code (updated): 0x0000000020060400
VID/DID: 0x00000000000014e4/0x0000000000002711
Header type: 0x0000000000000001

           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  fd500000 e4 14 11 27 00 00 10 00 20 00 04 06 00 00 01 00 00 00 00 00 00 00 00 00 00 01 01 00 00 00 00 00
  fd500020 00 f8 00 f8 f1 ff 01 00 00 00 00 00 00 00 00 00 00 00 00 00 48 00 00 00 00 00 00 00 00 01 00 00

Vendor ID: 14e4
Device ID: 2711
Command: 0000 (Linux: 0060)
Status: 0010
Revision ID: 20
Prog IF: 00
Subclass: 04
Class code: 06
Cache line size: 00
Latency timer: 00
Header type: 01
BIST: 00
BAR0: 00000000
BAR1: 00000000
Primary Bus Number: 00
Secondary Bus Number: 01
Subordinate Bus Number: 01
Secondary Latency Timer: 00
I/O Base: 00
I/O Limit: 00
Secondary Status: 0000
Memory Base: f800 (Linux: c000)
Memory Limit: f800 (Linux: c000)
Prefetchable Memory Base: fff1
Prefetchable Memory Limit: 0001
Prefetchable Base Upper 32 bits: 00000000
Prefetchable Limit Upper 32 bits: 00000000
I/O Base Upper 16 bits: 0000
I/O Limit Upper 16 bits: 0000
Capability Pointer: 48
Reserved: 000000
Expansion ROM base address: 00000000
Interrupt Line: 00
Interrupt Pin: 01
Bridge Control: 0000


  fd500040 00 00 00 00 00 00 00 00 01 ac 13 48 08 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500060 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500080 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5000a0 00 00 00 00 00 00 00 00 00 00 00 00 10 00 42 00 02 80 00 00 10 2c 00 00 12 5c 65 00 00 00 12 90
  fd5000c0 00 00 00 00 00 00 40 00 00 00 01 00 00 00 00 00 1f 08 08 00 00 00 00 00 06 00 00 80 02 00 00 00
  fd5000e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500100 01 00 01 18 00 00 00 00 00 00 00 00 30 20 06 00 00 00 00 00 00 20 00 00 00 00 00 00 00 00 00 00
  fd500120 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500180 0b 00 01 24 00 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5001a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5001c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5001e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500200 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500220 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500240 1e 00 01 00 1f 08 28 00 00 01 00 00 28 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500260 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500280 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5002a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5002c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5002e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500300 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500320 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500340 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500360 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500380 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5003a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5003c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5003e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500400 00 00 00 00 00 00 00 00 10 00 01 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500420 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 11 27 e4 14 e4 14 11 27 00 04 06 20
  fd500440 48 30 00 00 e4 0a 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500460 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500480 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5004a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5004c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 00 02 80 00 00 00 00 00 00 12 5e 31 00
  fd5004e0 00 00 00 00 1f 00 08 00 00 00 00 80 00 00 00 00 02 00 00 00 00 00 00 00 0f 00 00 00 00 00 00 00
  fd500500 03 00 01 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500520 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500540 1f 08 28 00 1e 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 02 0f 00 00 00 00 00 00 00
  fd500560 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500580 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5005a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5005c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5005e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500600 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500620 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500640 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500660 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd500680 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  fd5006a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```



```
pcie_bridge_sw_init_set(1)
shift = m_reg_field_info[RGR1_SW_INIT_1_INIT_SHIFT] = m_reg_field_info[1]
u32 mask =  m_reg_field_info[RGR1_SW_INIT_1_INIT_MASK] = m_reg_field_info[0]
wr_fld_rb(m_base + PCIE_RGR1_SW_INIT_1, mask, shift, val); = wr_fld_rb(m_base + m_reg_offsets[RGR1_SW_INIT_1], m_reg_field_info[0], m_reg_field_info[1], 1) = wr_fld_rb(m_base + m_reg_offsets[0], m_reg_field_info[0], m_reg_field_info[1], 1)
m_reg_offsets[RGR1_SW_INIT_1] = write/readback field (m_base+0x9210, 0x2, 0x1, 1)


wr_fld_rb(0xFD509210, 2=mask, 1=shift, 1=value)  =>  set bit 1 of 0Xfd509210
```

* https://olegkutkov.me/2021/01/07/writing-a-pci-device-driver-for-linux/

## Building Linux kernel under docker (e.g. on macOS)

```bash
docker run --name rpikernel -v /Volumes/casesensitive/linux -ti ubuntu /bin/bash
apt-get update
apt-get upgrade
apt install git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64
export KERNEL=kernel8
git clone git@github.com:petemoore/linux.git
cd linux
git switch -c rpi-5.15.y --track origin/rpi-5.15.y
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig
sed -i 's/^\(CONFIG_LOCALVERSION=.*\)"/\1-pmoore"/' .config
sed -i 's/-pmoore-pmoore/-pmoore/' .config
sed -i 's/^# CONFIG_WERROR is not set/CONFIG_WERROR=y/' .config
sed -i '/^# ARMv8\.1 architectural features/,/^# end of Kernel Features/ s/=\y/=n/' .config

function set-config {
  var="${1}"
  val="${2}"
  if ! grep -q "^${var}=${val}$" .config; then
    sed -i "s/^${var}=/# &/" .config
    echo "${var}=${val}" >> .config
  fi
}

set-config CONFIG_DEBUG_KERNEL y
set-config CONFIG_DEBUG_INFO y
set-config CONFIG_DEBUG_INFO_REDUCED n
set-config CONFIG_DEBUG_INFO_DWARF5 y
set-config CONFIG_FRAME_POINTER y

# make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j Image modules dtbs
make -j8 Image.gz modules dtbs
objdump -d vmlinux > kernel.s

# kernel8.img can be copied from arch/arm64/boot/Image.gz
# Use with https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2023-02-22/

docker start -i $(docker ps -q -l)
docker start -i rpikernel
```

## Logging mmio read/writes in dmesg logs

```
git reset --hard HEAD; git clean -fdx
git grep -l '\(read\|write\)l' | grep '\.c$' | while read file; do if ! grep -q 'pete_\(read\|write\)l' "${file}"; then echo "processing ${file}..."; git checkout "${file}"; cat "${file}" | sed 's/readl(/pete_&/g' | sed 's/writel(/pete_&/g' | sed 's/_pete_readl/_readl/g' | sed 's/_pete_writel/_writel/g' > y; cat y | grep -n 'pete_\(read\|write\)l' | sed 's/:.*//' | while read line; do cat y | sed "${line}s%pete_readl(%&\"${file}:${line}\", %g" | sed "${line}s%pete_writel(%&\"${file}:${line}\", %g" > x; mv x y; done; mv y "${file}"; fi; done
```

## Building Linux kernel directly on rpi

```
sudo apt install git bc bison flex libssl-dev make
export KERNEL=kernel8 # examples online didn't export, but I have no idea how it reaches make subprocess if not exported
make bcm2711_defconfig
sed -i 's/^\(CONFIG_LOCALVERSION=.*\)"/\1-pmoore"/' .config
sed -i 's/-pmoore-pmoore/-pmoore/' .config
sed -i 's/^# CONFIG_WERROR is not set/CONFIG_WERROR=y/' .config
# sed -i 's/^\(CONFIG_LOG_BUF_SHIFT=\).*/\118/' .config  # (note, this sets the _default_ kernel ring buffer size when an explicit value is not specified in /boot/cmdline.txt - so probably better to just specify in /boot/cmdline.txt instead, and leave the default settings alone)
make -j8 Image.gz

# note - if you get errors about 128 bit integer types, it probably means you are in a 32 bit userspace (file /bin/bash should give you an idea)
# make sure you installed a 64 bit version of Raspbian OS etc, not the standard 32 bit version

sudo cp arch/arm64/boot/Image.gz /boot/kernel8.img

make drivers/pci/controller/pcie-brcmstb.i

edit /boot/cmdline.txt: add `log_buf_len=64M` (`log-buf-len=64M` should also work)

# then boot into kernel, and run
dmesg > dmesg.log 2>&1
scp dmesg.log pmoore@Petes-iMac.local:.  # (for example)
```

## Linux call stack

* [brcm_pcie_probe](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/controller/pcie-brcmstb.c#L1250) calls [pci_host_probe](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/controller/pcie-brcmstb.c#L1376)
* [pci_host_probe](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L3022) calls [pci_scan_root_bus_bridge](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L3027)
* [pci_scan_root_bus_bridge](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L3116) calls [pci_scan_child_bus](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L3147)
* [pci_scan_child_bus](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2967) calls [pci_scan_child_bus_extend](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2969)
* [pci_scan_child_bus_extend](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2826) calls [pci_scan_slot](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2839)
* [pci_scan_slot](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2614) calls [pci_scan_single_device](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2622)
* [pci_scan_single_device](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2533) calls [pci_scan_device](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2543)
* [pci_scan_device](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2373) calls [pci_bus_read_dev_vendor_id](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2378)
* [pci_bus_read_dev_vendor_id](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2350) calls [pci_bus_generic_read_dev_vendor_id](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2365)
* [pci_bus_generic_read_dev_vendor_id](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2333) calls [pci_bus_read_config_dword](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/probe.c#L2336)
* [pci_bus_read_config_dword](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/access.c#L36) calls [pci_generic_config_read](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/access.c#L44)
* [pci_generic_config_read](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/access.c#L77) calls [pete_readl](https://github.com/petemoore/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/drivers/pci/access.c#L93)




https://github.com/raspberrypi/linux/blob/3ea9b35bd3eef731a94c48e197d4ea1539f3aae2/include/linux/pci.h#L626-L660

```
struct pci_bus {
    struct list_head node;        /* Node in list of buses */
    struct pci_bus    *parent;    /* Parent bus this bridge is on */
    struct list_head children;    /* List of child buses */
    struct list_head devices;    /* List of devices on this bus */
    struct pci_dev    *self;        /* Bridge device as seen by parent */
    struct list_head slots;        /* List of slots on this bus;
                       protected by pci_slot_mutex */
    struct resource *resource[PCI_BRIDGE_RESOURCE_NUM];
    struct list_head resources;    /* Address space routed to this bus */
    struct resource busn_res;    /* Bus numbers routed to this bus */

    struct pci_ops    *ops;        /* Configuration access functions */
    void        *sysdata;    /* Hook for sys-specific extension */
    struct proc_dir_entry *procdir;    /* Directory entry in /proc/bus/pci */

    unsigned char    number;        /* Bus number */
    unsigned char    primary;    /* Number of primary bridge */
    unsigned char    max_bus_speed;    /* enum pci_bus_speed */
    unsigned char    cur_bus_speed;    /* enum pci_bus_speed */
#ifdef CONFIG_PCI_DOMAINS_GENERIC
    int        domain_nr;
#endif

    char        name[48];

    unsigned short    bridge_ctl;    /* Manage NO_ISA/FBB/et al behaviors */
    pci_bus_flags_t bus_flags;    /* Inherited by child buses */
    struct device        *bridge;
    struct device        dev;
    struct bin_attribute    *legacy_io;    /* Legacy I/O for this bus */
    struct bin_attribute    *legacy_mem;    /* Legacy mem */
    unsigned int        is_added:1;
    unsigned int        unsafe_warn:1;    /* warned about RW1C config write */
};
```


```
struct pci_ops {
    int (*add_bus)(struct pci_bus *bus);
    void (*remove_bus)(struct pci_bus *bus);
    void __iomem *(*map_bus)(struct pci_bus *bus, unsigned int devfn, int where);          //// on rpi400 that is brcm_pcie_map_conf
    int (*read)(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *val);   //// or rpi400 that is pci_generic_config_read
    int (*write)(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 val);   //// or rpi400 that is pci_generic_config_write
};
```

```

static struct pci_ops brcm_pcie_ops = {
    .map_bus = brcm_pcie_map_conf,
    .read = pci_generic_config_read,
    .write = pci_generic_config_write,
};

```


```
#define PCI_SLOT(devfn)        (((devfn) >> 3) & 0x1f)
```


```
static void __iomem *brcm_pcie_map_conf(struct pci_bus *bus, unsigned int devfn,
                    int where)
{
    struct brcm_pcie *pcie = bus->sysdata;
    void __iomem *base = pcie->base;
    int idx;

    /* Accesses to the RC go right to the RC registers if slot==0 */
    if (pci_is_root_bus(bus))
        return PCI_SLOT(devfn) ? NULL : base + where;
// #define PCI_SLOT(devfn)     (((devfn) >> 3) & 0x1f)

    /* For devices, write to the config space index register */
    idx = PCIE_ECAM_OFFSET(bus->number, devfn, 0);
    writel(idx, pcie->base + PCIE_EXT_CFG_INDEX);
    return base + PCIE_EXT_CFG_DATA + where;
// #define PCIE_EXT_CFG_DATA                0x8000
}
```

```
/*
 * Enhanced Configuration Access Mechanism (ECAM)
 *
 * See PCI Express Base Specification, Revision 5.0, Version 1.0,
 * Section 7.2.2, Table 7-1, p. 677.
 */
#define PCIE_ECAM_BUS_SHIFT    20 /* Bus number */
#define PCIE_ECAM_DEVFN_SHIFT    12 /* Device and Function number */

#define PCIE_ECAM_BUS_MASK    0xff
#define PCIE_ECAM_DEVFN_MASK    0xff
#define PCIE_ECAM_REG_MASK    0xfff /* Limit offset to a maximum of 4K */

#define PCIE_ECAM_BUS(x)    (((x) & PCIE_ECAM_BUS_MASK) << PCIE_ECAM_BUS_SHIFT)
#define PCIE_ECAM_DEVFN(x)    (((x) & PCIE_ECAM_DEVFN_MASK) << PCIE_ECAM_DEVFN_SHIFT)
#define PCIE_ECAM_REG(x)    ((x) & PCIE_ECAM_REG_MASK)

#define PCIE_ECAM_OFFSET(bus, devfn, where) \
    (PCIE_ECAM_BUS(bus) | \
     PCIE_ECAM_DEVFN(devfn) | \
     PCIE_ECAM_REG(where))
```



```
/* The pci_dev structure describes PCI devices */
struct pci_dev {
    struct list_head bus_list;    /* Node in per-bus list */
    struct pci_bus    *bus;        /* Bus this device is on */
    struct pci_bus    *subordinate;    /* Bus this device bridges to */

    void        *sysdata;    /* Hook for sys-specific extension */
    struct proc_dir_entry *procent;    /* Device entry in /proc/bus/pci */
    struct pci_slot    *slot;        /* Physical slot this device is in */

    unsigned int    devfn;        /* Encoded device & function index */
    unsigned short    vendor;
    unsigned short    device;
    unsigned short    subsystem_vendor;
    unsigned short    subsystem_device;
    unsigned int    class;        /* 3 bytes: (base,sub,prog-if) */
    u8        revision;    /* PCI revision, low byte of class word */
    u8        hdr_type;    /* PCI header type (`multi' flag masked out) */
#ifdef CONFIG_PCIEAER
    u16        aer_cap;    /* AER capability offset */
    struct aer_stats *aer_stats;    /* AER stats for this device */
#endif
#ifdef CONFIG_PCIEPORTBUS
    struct rcec_ea    *rcec_ea;    /* RCEC cached endpoint association */
    struct pci_dev  *rcec;          /* Associated RCEC device */
#endif
    u32        devcap;        /* PCIe Device Capabilities */
    u8        pcie_cap;    /* PCIe capability offset */
    u8        msi_cap;    /* MSI capability offset */
    u8        msix_cap;    /* MSI-X capability offset */
    u8        pcie_mpss:3;    /* PCIe Max Payload Size Supported */
    u8        rom_base_reg;    /* Config register controlling ROM */
    u8        pin;        /* Interrupt pin this device uses */
    u16        pcie_flags_reg;    /* Cached PCIe Capabilities Register */
    unsigned long    *dma_alias_mask;/* Mask of enabled devfn aliases */

    struct pci_driver *driver;    /* Driver bound to this device */
    u64        dma_mask;    /* Mask of the bits of bus address this
                       device implements.  Normally this is
                       0xffffffff.  You only need to change
                       this if your device has broken DMA
                       or supports 64-bit transfers.  */

    struct device_dma_parameters dma_parms;

    pci_power_t    current_state;    /* Current operating state. In ACPI,
                       this is D0-D3, D0 being fully
                       functional, and D3 being off. */
    unsigned int    imm_ready:1;    /* Supports Immediate Readiness */
    u8        pm_cap;        /* PM capability offset */
    unsigned int    pme_support:5;    /* Bitmask of states from which PME#
                       can be generated */
    unsigned int    pme_poll:1;    /* Poll device's PME status bit */
    unsigned int    d1_support:1;    /* Low power state D1 is supported */
    unsigned int    d2_support:1;    /* Low power state D2 is supported */
    unsigned int    no_d1d2:1;    /* D1 and D2 are forbidden */
    unsigned int    no_d3cold:1;    /* D3cold is forbidden */
    unsigned int    bridge_d3:1;    /* Allow D3 for bridge */
    unsigned int    d3cold_allowed:1;    /* D3cold is allowed by user */
    unsigned int    mmio_always_on:1;    /* Disallow turning off io/mem
                           decoding during BAR sizing */
    unsigned int    wakeup_prepared:1;
    unsigned int    runtime_d3cold:1;    /* Whether go through runtime
                           D3cold, not set for devices
                           powered on/off by the
                           corresponding bridge */
    unsigned int    skip_bus_pm:1;    /* Internal: Skip bus-level PM */
    unsigned int    ignore_hotplug:1;    /* Ignore hotplug events */
    unsigned int    hotplug_user_indicators:1; /* SlotCtl indicators
                              controlled exclusively by
                              user sysfs */
    unsigned int    clear_retrain_link:1;    /* Need to clear Retrain Link
                           bit manually */
    unsigned int    d3hot_delay;    /* D3hot->D0 transition time in ms */
    unsigned int    d3cold_delay;    /* D3cold->D0 transition time in ms */

#ifdef CONFIG_PCIEASPM
    struct pcie_link_state    *link_state;    /* ASPM link state */
    unsigned int    ltr_path:1;    /* Latency Tolerance Reporting
                       supported from root to here */
    u16        l1ss;        /* L1SS Capability pointer */
#endif
    unsigned int    pasid_no_tlp:1;        /* PASID works without TLP Prefix */
    unsigned int    eetlp_prefix_path:1;    /* End-to-End TLP Prefix */

    pci_channel_state_t error_state;    /* Current connectivity state */
    struct device    dev;            /* Generic device interface */

    int        cfg_size;        /* Size of config space */

    /*
     * Instead of touching interrupt line and base address registers
     * directly, use the values stored here. They might be different!
     */
    unsigned int    irq;
    struct resource resource[DEVICE_COUNT_RESOURCE]; /* I/O and memory regions + expansion ROMs */

    bool        match_driver;        /* Skip attaching driver */

    unsigned int    transparent:1;        /* Subtractive decode bridge */
    unsigned int    io_window:1;        /* Bridge has I/O window */
    unsigned int    pref_window:1;        /* Bridge has pref mem window */
    unsigned int    pref_64_window:1;    /* Pref mem window is 64-bit */
    unsigned int    multifunction:1;    /* Multi-function device */

    unsigned int    is_busmaster:1;        /* Is busmaster */
    unsigned int    no_msi:1;        /* May not use MSI */
    unsigned int    no_64bit_msi:1;        /* May only use 32-bit MSIs */
    unsigned int    block_cfg_access:1;    /* Config space access blocked */
    unsigned int    broken_parity_status:1;    /* Generates false positive parity */
    unsigned int    irq_reroute_variant:2;    /* Needs IRQ rerouting variant */
    unsigned int    msi_enabled:1;
    unsigned int    msix_enabled:1;
    unsigned int    ari_enabled:1;        /* ARI forwarding */
    unsigned int    ats_enabled:1;        /* Address Translation Svc */
    unsigned int    pasid_enabled:1;    /* Process Address Space ID */
    unsigned int    pri_enabled:1;        /* Page Request Interface */
    unsigned int    is_managed:1;
    unsigned int    needs_freset:1;        /* Requires fundamental reset */
    unsigned int    state_saved:1;
    unsigned int    is_physfn:1;
    unsigned int    is_virtfn:1;
    unsigned int    is_hotplug_bridge:1;
    unsigned int    shpc_managed:1;        /* SHPC owned by shpchp */
    unsigned int    is_thunderbolt:1;    /* Thunderbolt controller */
    /*
     * Devices marked being untrusted are the ones that can potentially
     * execute DMA attacks and similar. They are typically connected
     * through external ports such as Thunderbolt but not limited to
     * that. When an IOMMU is enabled they should be getting full
     * mappings to make sure they cannot access arbitrary memory.
     */
    unsigned int    untrusted:1;
    /*
     * Info from the platform, e.g., ACPI or device tree, may mark a
     * device as "external-facing".  An external-facing device is
     * itself internal but devices downstream from it are external.
     */
    unsigned int    external_facing:1;
    unsigned int    broken_intx_masking:1;    /* INTx masking can't be used */
    unsigned int    io_window_1k:1;        /* Intel bridge 1K I/O windows */
    unsigned int    irq_managed:1;
    unsigned int    non_compliant_bars:1;    /* Broken BARs; ignore them */
    unsigned int    is_probed:1;        /* Device probing in progress */
    unsigned int    link_active_reporting:1;/* Device capable of reporting link active */
    unsigned int    no_vf_scan:1;        /* Don't scan for VFs after IOV enablement */
    unsigned int    no_command_memory:1;    /* No PCI_COMMAND_MEMORY */
    pci_dev_flags_t dev_flags;
    atomic_t    enable_cnt;    /* pci_enable_device has been called */

    u32        saved_config_space[16]; /* Config space saved at suspend time */
    struct hlist_head saved_cap_space;
    int        rom_attr_enabled;    /* Display of ROM attribute enabled? */
    struct bin_attribute *res_attr[DEVICE_COUNT_RESOURCE]; /* sysfs file for resources */
    struct bin_attribute *res_attr_wc[DEVICE_COUNT_RESOURCE]; /* sysfs file for WC mapping of resources */

#ifdef CONFIG_HOTPLUG_PCI_PCIE
    unsigned int    broken_cmd_compl:1;    /* No compl for some cmds */
#endif
#ifdef CONFIG_PCIE_PTM
    unsigned int    ptm_root:1;
    unsigned int    ptm_enabled:1;
    u8        ptm_granularity;
#endif
#ifdef CONFIG_PCI_MSI
    const struct attribute_group **msi_irq_groups;
#endif
    struct pci_vpd    vpd;
#ifdef CONFIG_PCIE_DPC
    u16        dpc_cap;
    unsigned int    dpc_rp_extensions:1;
    u8        dpc_rp_log_size;
#endif
#ifdef CONFIG_PCI_ATS
    union {
        struct pci_sriov    *sriov;        /* PF: SR-IOV info */
        struct pci_dev        *physfn;    /* VF: related PF */
    };
    u16        ats_cap;    /* ATS Capability offset */
    u8        ats_stu;    /* ATS Smallest Translation Unit */
#endif
#ifdef CONFIG_PCI_PRI
    u16        pri_cap;    /* PRI Capability offset */
    u32        pri_reqs_alloc; /* Number of PRI requests allocated */
    unsigned int    pasid_required:1; /* PRG Response PASID Required */
#endif
#ifdef CONFIG_PCI_PASID
    u16        pasid_cap;    /* PASID Capability offset */
    u16        pasid_features;
#endif
#ifdef CONFIG_PCI_P2PDMA
    struct pci_p2pdma __rcu *p2pdma;
#endif
    u16        acs_cap;    /* ACS Capability offset */
    phys_addr_t    rom;        /* Physical address if not from BAR */
    size_t        romlen;        /* Length if not from BAR */
    char        *driver_override; /* Driver name to force a match */

    unsigned long    priv_flags;    /* Private flags for the PCI driver */

    /* These methods index pci_reset_fn_methods[] */
    u8 reset_methods[PCI_NUM_RESET_METHODS]; /* In priority order */
};
```

```
struct pcie_link_state {
    struct pci_dev *pdev;        /* Upstream component of the Link */
    struct pci_dev *downstream;    /* Downstream component, function 0 */
    struct pcie_link_state *root;    /* pointer to the root port link */
    struct pcie_link_state *parent;    /* pointer to the parent Link state */
    struct list_head sibling;    /* node in link_list */

    /* ASPM state */
    u32 aspm_support:7;        /* Supported ASPM state */
    u32 aspm_enabled:7;        /* Enabled ASPM state */
    u32 aspm_capable:7;        /* Capable ASPM state with latency */
    u32 aspm_default:7;        /* Default ASPM state by BIOS */
    u32 aspm_disable:7;        /* Disabled ASPM state */

    /* Clock PM state */
    u32 clkpm_capable:1;        /* Clock PM capable? */
    u32 clkpm_enabled:1;        /* Current Clock PM state */
    u32 clkpm_default:1;        /* Default Clock PM state by BIOS */
    u32 clkpm_disable:1;        /* Clock PM disabled */
};
```

```
struct pcie_cfg_data {
    const int *offsets;
    const enum pcie_type type;
    void (*perst_set)(struct brcm_pcie *pcie, u32 val);
    void (*bridge_sw_init_set)(struct brcm_pcie *pcie, u32 val);
};
```

```
enum pcie_type {
    GENERIC,
    BCM4908,
    BCM7278,
    BCM2711,
};
```

```
/* Internal PCIe Host Controller Information.*/
struct brcm_pcie {
    struct device        *dev;
    void __iomem        *base;
    struct clk        *clk;
    struct device_node    *np;
    bool            ssc;
    bool            l1ss;
    int            gen;
    u64            msi_target_addr;
    struct brcm_msi        *msi;
    const int        *reg_offsets;
    enum pcie_type        type;
    struct reset_control    *rescal;
    struct reset_control    *perst_reset;
    int            num_memc;
    u64            memc_size[PCIE_BRCM_MAX_MEMC];
    u32            hw_rev;
    void            (*perst_set)(struct brcm_pcie *pcie, u32 val);
    void            (*bridge_sw_init_set)(struct brcm_pcie *pcie, u32 val);
};
```

```
/*
 * Returns true if the PCI bus is root (behind host-PCI bridge),
 * false otherwise
 *
 * Some code assumes that "bus->self == NULL" means that bus is a root bus.
 * This is incorrect because "virtual" buses added for SR-IOV (via
 * virtfn_add_bus()) have "bus->self == NULL" but are not root buses.
 */
static inline bool pci_is_root_bus(struct pci_bus *pbus)
{
    return !(pbus->parent);
}
```


```
/**
 * Returns the pcie register address that maps to the given pci bus, function and
 * config offset (where).  If the pci bus has no parent, this will be the offset
 * from the pcie base, otherwise PCIE_EXT_CFG_INDEX register will be written to
 * with the ECAM offset for bus/function, and offset (where) will be applied to
 * PCIE_EXT_CFG_DATA. If no bus parent, but device (slot) is not 0, return 0.
 */
static void __iomem *brcm_pcie_map_conf(struct pci_bus *bus, unsigned int devfn, int where)



/**
 * Reads byte/word/dword into val for given inputs. Calls brcm_pcie_map_conf to
 * get address. Returns PCIBIOS_DEVICE_NOT_FOUND / PCIBIOS_SUCCESSFUL
 */
pci_generic_config_read(struct pci_bus *bus, unsigned int devfn, int where, int size, u32 *val)


/**
 * Wrapper for pci_generic_config_read that returns PCIBIOS_BAD_REGISTER_NUMBER if
 * pos/size misaligned. Spinlock around access (raw_spin_lock_irqsave).
 */
pci_bus_read_config_{byte,word,dword==size} (struct pci_bus *bus, unsigned int devfn, int pos, type *value)



/**
 * Reads vendorid (where=0, size=4) into l. If two upper bytes or two lower bytes
 * == 0x0000 or 0xffff, returns false.  If Vendor (l & 0xffff) comes back as
 * 0x0001, keep retrying until timeout with exponential backoff. Return true if
 * value not 0x0001, otherwise false.
 */
bool pci_bus_generic_read_dev_vendor_id(struct pci_bus *bus, int devfn, u32 *l, int timeout)


/**
 * Allocate a pci_dev struct from the pci_bus struct passed in. Initialise bus_list (doubly linked list), type
 * (pci_dev_type), bus = bus->dev of bus passed in (taking care of reference counting).
 */
struct pci_dev *pci_alloc_dev(struct pci_bus *bus)


/**
 * Call pci_bus_generic_read_dev_vendor_id to get vendor/device id (60 second
 * timeout or fail).  Allocate a pci_dev device (dev) by calling pci_alloc_dev(bus).
 * Then set dev->devfn, dev->vendor and dev->device. Call pci_setup_device(dev) and if
 * that fails, free the device, otherwise return it.
 */
static struct pci_dev *pci_scan_device(struct pci_bus *bus, int devfn)



/**
 * pci_setup_device - Fill in class and map information of a device
 * @dev: the device structure to fill
 *
 * Initialize the device structure with information about the device's
 * vendor,class,memory and IO-space addresses, IRQ lines etc.
 * Called at initialisation of the PCI subsystem and by CardBus services.
 * Returns 0 on success and negative if unknown type of device (not normal,
 * bridge or CardBus).
 */
int pci_setup_device(struct pci_dev *dev)
```



# GIC configuration

These reads/writes are captures in dmesg.log

### Reads

```
Read 32 bits [0xffffffc081582000]     GICC_CTLR
Read 32 bits [0xffffffc08158200c]     GICC_IAR
Read 32 bits [0xffffffc0815820fc]     GICC_IIDR
```

### Writes

```
Write 32 bits [0xffffffc081582000]    GICC_CTLR
Write 32 bits [0xffffffc081582004]    GICC_PMR
Write 32 bits [0xffffffc081582010]    GICC_EOIR
Write 32 bits [0xffffffc0815820d0]    GICC_APR0
Write 32 bits [0xffffffc0815820d4]    GICC_APR1
Write 32 bits [0xffffffc0815820d8]    GICC_APR2
Write 32 bits [0xffffffc0815820dc]    GICC_APR3
Write 32 bits [0xffffffc081583000]    GICC_DIR
```
