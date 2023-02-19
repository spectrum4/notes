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




Steps from linux kernel:
* set bit 1 of register [0xfd509210]
* sleep for 100-200 microseconds
* clear bit 1 or [0xfd509210]
* clear bit 27 of [0xfd504204]
* sleep for 100-200 microseconds
* set bits 7, 10, 12, 13 and clear bits 20, 21 of [0xfd504008]




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
Command: 0000
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
Memory Base: f800
Memory Limit: f800
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

```bash
docker start -i $(docker ps -q -l)
git grep -l '\(readl\|writel\)' | grep '\.c$' | while read file; do if ! grep -q 'pete_\(read\|write\)l' "${file}"; then echo "processing ${file}..."; git checkout "${file}"; cat "${file}" | sed 's/readl(/pete_&/g' | sed 's/writel(/pete_&/g' | sed 's/_pete_/_/g' > y; cat y | grep -n pete_ | sed 's/:.*//' | while read line; do cat y | sed "${line}s%pete_[^(]*(%&\"${file}:${line}\", %g" > x; mv x y; done; mv y "${file}"; fi; done
KERNEL=kernel8
make drivers/pci/controller/pcie-brcmstb.i
make -j8 Image.gz
```
