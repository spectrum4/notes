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

pcie regs = Address 0xfd500000 (size 0x9310)

matches: arch/arm/boot/dts/bcm2711.dtsi

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




PCIe revision: 0x0000000000000304
PCIe link is ready
PCIe status register: 0x00000000000000b0
PCIe loop iterations: 0x000000000000002e
PCIe class code (initial): 0x0000000020060400
PCIe class code (updated): 0x0000000020060400
VID/DID: 0x00000000000014e4/0x0000000000002711
Header type: 0x0000000000000001
