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
* set bit 1 of register [0xfd509210] (0xfd500000 + 0x9210)
* sleep for 100-200 microseconds
* clear bit 1 or [0xfd509210]
* clear bit 27 of [0xfd504204]
* sleep for 100-200 microseconds
* set bits 7, 10, 12, 13 and clear bits 20, 21 of [0xfd504008]

Steps from dmesg debug logs:
[    1.210376] brcm-pcie fd500000.pcie: host bridge /scb/pcie@7d500000 ranges:
[    1.210415] brcm-pcie fd500000.pcie:   No bus range found for /scb/pcie@7d500000, using [bus 00-ff]
[    1.210561] brcm-pcie fd500000.pcie:      MEM 0x0600000000..0x063fffffff -> 0x00c0000000
[    1.210651] brcm-pcie fd500000.pcie:   IB MEM 0x0000000000..0x00ffffffff -> 0x0400000000
[    1.210742] brcm-pcie fd500000.pcie: pdev->name: fd500000.pcie
[    1.210756] brcm-pcie fd500000.pcie: pdev->id: 0xffffffff
[    1.210768] brcm-pcie fd500000.pcie: pdev->id_auto: false
[    1.210780] brcm-pcie fd500000.pcie: pdev->dev.init_name: (null)
[    1.210793] brcm-pcie fd500000.pcie: pdev->dev.platform_data: 0x0000000000000000
[    1.210809] brcm-pcie fd500000.pcie: pdev->platform_dma_mask: 0x00000000ffffffff
[    1.210822] brcm-pcie fd500000.pcie: pdev->num_resources: 0x3
[    1.210834] brcm-pcie fd500000.pcie: pdev->driver_override: (null)
[    1.210846] drivers/pci/controller/pcie-brcmstb.c:735 Read 32 bits [0xfd509210]=0x1
[    1.210859] drivers/pci/controller/pcie-brcmstb.c:737 Write 32 bits [0xfd509210]=0x3
[    1.210873] drivers/pci/controller/pcie-brcmstb.c:775 Read 32 bits [0xfd509210]=0x3
[    1.210885] drivers/pci/controller/pcie-brcmstb.c:777 Write 32 bits [0xfd509210]=0x3
[    1.211121] drivers/pci/controller/pcie-brcmstb.c:735 Read 32 bits [0xfd509210]=0x3
[    1.211136] drivers/pci/controller/pcie-brcmstb.c:737 Write 32 bits [0xfd509210]=0x1
[    1.211147] drivers/pci/controller/pcie-brcmstb.c:890 Read 32 bits [0xfd504204]=0x200000
[    1.211161] drivers/pci/controller/pcie-brcmstb.c:892 Write 32 bits [0xfd504204]=0x200000
[    1.211393] drivers/pci/controller/pcie-brcmstb.c:909 Read 32 bits [0xfd504008]=0x0
[    1.211407] drivers/pci/controller/pcie-brcmstb.c:913 Write 32 bits [0xfd504008]=0x3000
[    1.211424] drivers/pci/controller/pcie-brcmstb.c:923 Write 32 bits [0xfd504034]=0x11
[    1.211438] drivers/pci/controller/pcie-brcmstb.c:924 Write 32 bits [0xfd504038]=0x4
[    1.211450] drivers/pci/controller/pcie-brcmstb.c:927 Read 32 bits [0xfd504008]=0x3000
[    1.211462] drivers/pci/controller/pcie-brcmstb.c:938 Write 32 bits [0xfd504008]=0x88003000
[    1.211474] drivers/pci/controller/pcie-brcmstb.c:953 Read 32 bits [0xfd50402c]=0x0
[    1.211487] drivers/pci/controller/pcie-brcmstb.c:955 Write 32 bits [0xfd50402c]=0x0
[    1.211499] drivers/pci/controller/pcie-brcmstb.c:958 Read 32 bits [0xfd50403c]=0x0
[    1.211510] drivers/pci/controller/pcie-brcmstb.c:960 Write 32 bits [0xfd50403c]=0x0
[    1.211521] drivers/pci/controller/pcie-brcmstb.c:775 Read 32 bits [0xfd509210]=0x1
[    1.211533] drivers/pci/controller/pcie-brcmstb.c:777 Write 32 bits [0xfd509210]=0x0
[    1.211544] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.226475] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.242470] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.258470] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0x80
[    1.274469] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0xb0
[    1.274484] drivers/pci/controller/pcie-brcmstb.c:700 Read 32 bits [0xfd504068]=0xb0
[    1.274496] drivers/pci/controller/pcie-brcmstb.c:693 Read 32 bits [0xfd504068]=0xb0
[    1.274510] drivers/pci/controller/pcie-brcmstb.c:434 Write 32 bits [0xfd50400c]=0xc0000000
[    1.274522] drivers/pci/controller/pcie-brcmstb.c:435 Write 32 bits [0xfd504010]=0x0
[    1.274534] drivers/pci/controller/pcie-brcmstb.c:441 Read 32 bits [0xfd504070]=0x10
[    1.274545] drivers/pci/controller/pcie-brcmstb.c:446 Write 32 bits [0xfd504070]=0x3ff00000
[    1.274557] drivers/pci/controller/pcie-brcmstb.c:453 Read 32 bits [0xfd504080]=0x0
[    1.274569] drivers/pci/controller/pcie-brcmstb.c:456 Write 32 bits [0xfd504080]=0x6
[    1.274580] drivers/pci/controller/pcie-brcmstb.c:459 Read 32 bits [0xfd504084]=0x0
[    1.274592] drivers/pci/controller/pcie-brcmstb.c:462 Write 32 bits [0xfd504084]=0x6
[    1.274606] drivers/pci/controller/pcie-brcmstb.c:1006 Read 32 bits [0xfd5004dc]=0x315e12
[    1.274618] drivers/pci/controller/pcie-brcmstb.c:1009 Write 32 bits [0xfd5004dc]=0x315e12
[    1.274630] drivers/pci/controller/pcie-brcmstb.c:1015 Read 32 bits [0xfd50043c]=0x20060400
[    1.274642] drivers/pci/controller/pcie-brcmstb.c:1018 Write 32 bits [0xfd50043c]=0x20060400
[    1.274654] drivers/pci/controller/pcie-brcmstb.c:358 Write 32 bits [0xfd501100]=0x1f
[    1.274666] drivers/pci/controller/pcie-brcmstb.c:360 Read 32 bits [0xfd501100]=0x1f
[    1.274677] drivers/pci/controller/pcie-brcmstb.c:361 Write 32 bits [0xfd501104]=0x80001100
[    1.274689] drivers/pci/controller/pcie-brcmstb.c:363 Read 32 bits [0xfd501104]=0x80001100
[    1.274713] drivers/pci/controller/pcie-brcmstb.c:366 Read 32 bits [0xfd501104]=0x1100
[    1.274725] drivers/pci/controller/pcie-brcmstb.c:337 Write 32 bits [0xfd501100]=0x100002
[    1.274737] drivers/pci/controller/pcie-brcmstb.c:339 Read 32 bits [0xfd501100]=0x100002
[    1.274748] drivers/pci/controller/pcie-brcmstb.c:341 Read 32 bits [0xfd501108]=0x8000803a
[    1.274761] drivers/pci/controller/pcie-brcmstb.c:358 Write 32 bits [0xfd501100]=0x2
[    1.274774] drivers/pci/controller/pcie-brcmstb.c:360 Read 32 bits [0xfd501100]=0x2
[    1.274785] drivers/pci/controller/pcie-brcmstb.c:361 Write 32 bits [0xfd501104]=0x8000c03a
[    1.274797] drivers/pci/controller/pcie-brcmstb.c:363 Read 32 bits [0xfd501104]=0x8000c03a
[    1.274819] drivers/pci/controller/pcie-brcmstb.c:366 Read 32 bits [0xfd501104]=0xc03a
[    1.276851] drivers/pci/controller/pcie-brcmstb.c:337 Write 32 bits [0xfd501100]=0x100001
[    1.276867] drivers/pci/controller/pcie-brcmstb.c:339 Read 32 bits [0xfd501100]=0x100001
[    1.276880] drivers/pci/controller/pcie-brcmstb.c:341 Read 32 bits [0xfd501108]=0x80001c17
[    1.276894] brcm-pcie fd500000.pcie: link up, 5.0 GT/s PCIe x1 (SSC)
[    1.276908] drivers/pci/controller/pcie-brcmstb.c:1036 Read 32 bits [0xfd500188]=0x0
[    1.276919] drivers/pci/controller/pcie-brcmstb.c:1039 Write 32 bits [0xfd500188]=0x0
[    1.276931] drivers/pci/controller/pcie-brcmstb.c:1041 Read 32 bits [0xfd504204]=0x200000
[    1.276942] drivers/pci/controller/pcie-brcmstb.c:1060 Write 32 bits [0xfd504204]=0x2
[    1.276954] drivers/pci/controller/pcie-brcmstb.c:1355 Read 32 bits [0xfd50406c]=0x304
[    1.277156] drivers/pci/controller/pcie-brcmstb.c:627 Write 32 bits [0xfd504514]=0xffffffff
[    1.277171] drivers/pci/controller/pcie-brcmstb.c:628 Write 32 bits [0xfd504508]=0xffffffff
[    1.277183] drivers/pci/controller/pcie-brcmstb.c:634 Write 32 bits [0xfd504044]=0xfffffffd
[    1.277194] drivers/pci/controller/pcie-brcmstb.c:636 Write 32 bits [0xfd504048]=0x0
[    1.277207] drivers/pci/controller/pcie-brcmstb.c:640 Write 32 bits [0xfd50404c]=0xffe06540
[    1.277385] brcm-pcie fd500000.pcie: PCI host bridge to bus 0000:00
[    1.277404] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.277422] pci_bus 0000:00: root bus resource [mem 0x600000000-0x63fffffff] (bus address [0xc0000000-0xffffffff])
[    1.277442] drivers/pci/access.c:93 Read 32 bits [0xfd500000]=0x271114e4
[    1.277473] drivers/pci/access.c:93 Read 32 bits [0xfd5000b0]=0x8002
[    1.277498] drivers/pci/access.c:93 Read 32 bits [0xfd500008]=0x6040020
[    1.277510] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.277519] drivers/pci/access.c:93 Read 32 bits [0xfd500000]=0x271114e4
[    1.277530] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.277541] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.277551] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.277560] drivers/pci/access.c:93 Read 32 bits [0xfd500184]=0x2800000
[    1.277570] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.277579] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.277595] pci 0000:00:00.0: [14e4:2711] type 01 class 0x060400
[    1.277633] drivers/pci/access.c:93 Read 32 bits [0xfd500010]=0x0
[    1.277644] drivers/pci/access.c:113 Write 32 bits [0xfd500010]=0xffffffff
[    1.277654] drivers/pci/access.c:93 Read 32 bits [0xfd500010]=0x0
[    1.277664] drivers/pci/access.c:113 Write 32 bits [0xfd500010]=0x0
[    1.277677] drivers/pci/access.c:93 Read 32 bits [0xfd500014]=0x0
[    1.277686] drivers/pci/access.c:113 Write 32 bits [0xfd500014]=0xffffffff
[    1.277696] drivers/pci/access.c:93 Read 32 bits [0xfd500014]=0x0
[    1.277705] drivers/pci/access.c:113 Write 32 bits [0xfd500014]=0x0
[    1.277717] drivers/pci/access.c:93 Read 32 bits [0xfd500038]=0x0
[    1.277726] drivers/pci/access.c:113 Write 32 bits [0xfd500038]=0xfffff800
[    1.277736] drivers/pci/access.c:93 Read 32 bits [0xfd500038]=0x0
[    1.277745] drivers/pci/access.c:113 Write 32 bits [0xfd500038]=0x0
[    1.277765] drivers/pci/access.c:93 Read 32 bits [0xfd500024]=0x1fff1
[    1.277774] drivers/pci/access.c:93 Read 32 bits [0xfd500028]=0x0
[    1.277783] drivers/pci/access.c:113 Write 32 bits [0xfd500028]=0xffffffff
[    1.277793] drivers/pci/access.c:93 Read 32 bits [0xfd500028]=0xffffffff
[    1.277802] drivers/pci/access.c:113 Write 32 bits [0xfd500028]=0x0
[    1.277824] drivers/pci/access.c:93 Read 32 bits [0xfd5000b0]=0x8002
[    1.277838] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.277847] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.277857] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.277866] drivers/pci/access.c:93 Read 32 bits [0xfd5000d0]=0x8081f
[    1.277876] drivers/pci/access.c:93 Read 32 bits [0xfd5000d4]=0x0
[    1.277952] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.277962] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.277972] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.277982] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.277991] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.278001] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.278010] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.278020] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.278029] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.278039] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.278049] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.278058] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.278096] pci 0000:00:00.0: PME# supported from D0 D3hot
[    1.278134] drivers/pci/access.c:93 Read 32 bits [0xfd500100]=0x18010001
[    1.278144] drivers/pci/access.c:93 Read 32 bits [0xfd500180]=0x2401000b
[    1.278153] drivers/pci/access.c:93 Read 32 bits [0xfd500240]=0x1001e
[    1.281843] drivers/pci/access.c:93 Read 32 bits [0xfd500018]=0x10100
[    1.281911] drivers/pci/access.c:93 Read 32 bits [0xfd5000b8]=0x655c12
[    1.282032] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282071] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
[    1.282099] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282138] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282180] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282222] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282265] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282307] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282349] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282391] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282431] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.282554] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282593] drivers/pci/access.c:93 Read 32 bits [0xfd508008]=0xc033001
[    1.282603] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282639] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.282648] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282685] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
[    1.282695] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282731] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.282741] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282777] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.282790] pci 0000:01:00.0: [1106:3483] type 00 class 0x0c0330
[    1.282807] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282846] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282888] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282930] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282942] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.282983] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283025] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283067] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283107] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0x4
[    1.283116] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283123] drivers/pci/access.c:113 Write 32 bits [0xfd508010]=0xffffffff
[    1.283161] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283201] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0xfffff004
[    1.283211] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283218] drivers/pci/access.c:113 Write 32 bits [0xfd508010]=0x4
[    1.283256] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283296] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0x0
[    1.283306] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283313] drivers/pci/access.c:113 Write 32 bits [0xfd508014]=0xffffffff
[    1.283352] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283392] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0xffffffff
[    1.283401] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283409] drivers/pci/access.c:113 Write 32 bits [0xfd508014]=0x0
[    1.283448] pci 0000:01:00.0: reg 0x10: [mem 0x00000000-0x00000fff 64bit]
[    1.283466] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283505] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283545] drivers/pci/access.c:93 Read 32 bits [0xfd508018]=0x0
[    1.283554] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283562] drivers/pci/access.c:113 Write 32 bits [0xfd508018]=0xffffffff
[    1.283600] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283640] drivers/pci/access.c:93 Read 32 bits [0xfd508018]=0x0
[    1.283649] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283656] drivers/pci/access.c:113 Write 32 bits [0xfd508018]=0x0
[    1.283694] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283736] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283776] drivers/pci/access.c:93 Read 32 bits [0xfd50801c]=0x0
[    1.283785] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283792] drivers/pci/access.c:113 Write 32 bits [0xfd50801c]=0xffffffff
[    1.283830] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283871] drivers/pci/access.c:93 Read 32 bits [0xfd50801c]=0x0
[    1.283879] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283887] drivers/pci/access.c:113 Write 32 bits [0xfd50801c]=0x0
[    1.283925] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.283967] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284007] drivers/pci/access.c:93 Read 32 bits [0xfd508020]=0x0
[    1.284016] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284023] drivers/pci/access.c:113 Write 32 bits [0xfd508020]=0xffffffff
[    1.284061] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284101] drivers/pci/access.c:93 Read 32 bits [0xfd508020]=0x0
[    1.284110] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284117] drivers/pci/access.c:113 Write 32 bits [0xfd508020]=0x0
[    1.284155] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284197] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284205] drivers/pci/access.c:93 Read 32 bits [0xfd508024]=0x0
[    1.284214] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284221] drivers/pci/access.c:113 Write 32 bits [0xfd508024]=0xffffffff
[    1.284258] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284299] drivers/pci/access.c:93 Read 32 bits [0xfd508024]=0x0
[    1.284307] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284315] drivers/pci/access.c:113 Write 32 bits [0xfd508024]=0x0
[    1.284353] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284395] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284435] drivers/pci/access.c:93 Read 32 bits [0xfd508030]=0x0
[    1.284444] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284451] drivers/pci/access.c:113 Write 32 bits [0xfd508030]=0xfffff800
[    1.284488] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284529] drivers/pci/access.c:93 Read 32 bits [0xfd508030]=0x0
[    1.284538] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284545] drivers/pci/access.c:113 Write 32 bits [0xfd508030]=0x0
[    1.284583] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284625] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284669] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284713] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284750] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.284760] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284800] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284808] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.284817] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284854] drivers/pci/access.c:93 Read 32 bits [0xfd5080e8]=0x12
[    1.284869] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284908] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284950] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.284992] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285035] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285077] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285119] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285161] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285203] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285246] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285288] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285330] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285372] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285414] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285456] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285499] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285541] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285583] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285625] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285667] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285711] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285752] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285794] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285836] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285878] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285921] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.285961] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.285970] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286006] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.286015] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286052] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.286061] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286097] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.286119] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286158] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286200] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286242] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286285] pci 0000:01:00.0: PME# supported from D0 D3hot
[    1.286299] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286338] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286381] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286422] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286481] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286521] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286563] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286605] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286648] drivers/pci/access.c:93 Read 32 bits [0xfd5000d0]=0x8081f
[    1.286658] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286695] drivers/pci/access.c:93 Read 32 bits [0xfd508100]=0x10001
[    1.286705] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286743] drivers/pci/access.c:93 Read 32 bits [0xfd5080f0]=0x0
[    1.286752] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286788] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.286798] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286834] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.286844] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286889] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286928] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.286970] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287012] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287054] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287097] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287445] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287485] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.287497] drivers/pci/access.c:93 Read 32 bits [0xfd5000b8]=0x655c12
[    1.287506] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287543] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.287552] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287596] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287636] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287689] drivers/pci/access.c:93 Read 32 bits [0xfd5000b8]=0x64cc12
[    1.287698] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287735] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.287747] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287786] drivers/pci/access.c:93 Read 32 bits [0xfd500244]=0x28081f
[    1.287797] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287833] drivers/pci/access.c:93 Read 32 bits [0xfd508004]=0x100000
[    1.287843] drivers/pci/access.c:93 Read 32 bits [0xfd500248]=0x100
[    1.287852] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287889] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[    1.287899] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287935] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[    1.287945] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.287985] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.288025] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291306] drivers/pci/access.c:93 Read 32 bits [0xfd500018]=0x10100
[    1.291353] pci 0000:00:00.0: BAR 8: assigned [mem 0x600000000-0x6000fffff]
[    1.291378] pci 0000:01:00.0: BAR 0: assigned [mem 0x600000000-0x600000fff 64bit]
[    1.291394] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291405] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291416] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291424] drivers/pci/access.c:113 Write 32 bits [0xfd508010]=0xc0000004
[    1.291434] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291442] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0xc0000004
[    1.291451] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291459] drivers/pci/access.c:113 Write 32 bits [0xfd508014]=0x0
[    1.291469] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291477] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0x0
[    1.291486] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.291498] pci 0000:00:00.0: PCI bridge to [bus 01]
[    1.291512] drivers/pci/access.c:113 Write 32 bits [0xfd500030]=0xffff
[    1.291524] drivers/pci/access.c:113 Write 32 bits [0xfd500030]=0x0
[    1.291533] pci 0000:00:00.0:   bridge window [mem 0x600000000-0x6000fffff]
[    1.291549] drivers/pci/access.c:113 Write 32 bits [0xfd500020]=0xc000c000
[    1.291560] drivers/pci/access.c:113 Write 32 bits [0xfd50002c]=0x0
[    1.291569] drivers/pci/access.c:113 Write 32 bits [0xfd500024]=0xfff0
[    1.291579] drivers/pci/access.c:113 Write 32 bits [0xfd500028]=0x0
[    1.291589] drivers/pci/access.c:113 Write 32 bits [0xfd50002c]=0x0
[    1.396142] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.396187] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.396329] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.444782] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.444822] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
[    1.444833] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.444875] drivers/pci/access.c:93 Read 32 bits [0xfd500000]=0x271114e4
[    1.444894] pci 0000:00:00.0: enabling device (0000 -> 0002)
[    1.444924] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.444965] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.445005] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.445122] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.445231] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.445511] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.445548] drivers/pci/access.c:93 Read 32 bits [0xfd508050]=0x138a1
[    1.446933] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.446947] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.446987] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447028] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447040] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447086] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447127] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447168] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447211] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447331] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447372] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447414] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447421] drivers/pci/access.c:113 Write 32 bits [0xfd508094]=0xfffffffc
[    1.447459] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447466] drivers/pci/access.c:113 Write 32 bits [0xfd508098]=0x0
[    1.447504] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447545] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447605] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447644] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447685] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.447727] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[    1.448981] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.448993] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.578781] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.578795] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.589703] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.589713] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.706735] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.706751] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.707351] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.707361] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.717972] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.717987] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.835116] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.835132] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.835577] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.835586] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.854736] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.854748] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.855148] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.855156] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.855614] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.855623] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.855983] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.855992] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.856392] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.856401] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.856759] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.856768] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.857151] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.857163] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.858097] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.858110] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.858667] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.858676] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.859428] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.859439] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.860002] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.860011] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.860477] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.860485] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.860819] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.860828] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.861164] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.861175] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.861799] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.861809] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.863648] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.863659] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.874816] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.874825] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.876640] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.876648] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.878464] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.878476] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.982742] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.982755] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.983090] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.983100] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.983446] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.983456] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.983806] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.983815] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.984158] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.984167] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    1.984513] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    1.984522] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.086750] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.086762] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.087101] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.087111] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.087273] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.087282] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.087822] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.087831] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.106707] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.106719] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.107075] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.107085] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.166688] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.166700] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.167804] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.167814] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.168054] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.168063] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.168371] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.168380] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.186751] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.186761] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.187119] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.187130] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.246793] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.246804] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.247304] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.247313] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.267825] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.267838] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.270820] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.270830] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.272695] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.272704] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.273320] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.273329] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.273569] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.273577] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.275944] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.275960] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.276194] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.276203] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.277070] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.277080] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.277319] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.277328] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.278376] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.278387] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.278675] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.278685] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.279012] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.279021] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.279826] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.279839] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.282322] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.282332] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.284446] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.284458] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.286285] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.286299] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.286683] input: PixArt Dell MS116 USB Optical Mouse as /devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.1/1-1.1:1.0/0003:413C:301A.0001/input/input0
[    2.287762] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.287771] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.288123] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.288132] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.288288] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.288297] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.288770] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.288780] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.310647] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.310658] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.311031] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.311041] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.370717] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.370728] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.376709] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.376717] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.376959] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.376967] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.377222] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.377232] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.394755] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.394765] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.395130] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.395139] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.454956] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.454972] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.456142] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.456177] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.480602] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.480625] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.487363] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.487414] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.506859] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.506890] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.511364] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.511381] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.511606] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.511620] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.530109] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.530122] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.530358] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.530375] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.534860] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.534888] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.535106] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.535115] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.536245] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.536257] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.536661] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.536671] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.537026] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.537035] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.537211] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.537220] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.537560] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.537569] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.541357] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.541367] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.544733] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.544743] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.562362] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.562376] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.564894] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.564904] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.565534] input:   Raspberry Pi Internal Keyboard as /devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04D9:0007.0002/input/input1
[    2.568862] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.568872] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.626121] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.626131] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.642123] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.642136] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.645110] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[    2.645121] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[    2.645440] input:   Raspberry Pi Internal Keyboard as /devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.4/1-1.4:1.1/0003:04D9:0007.0003/input/input2
[   24.912350] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912397] drivers/pci/access.c:93 Read 32 bits [0xfd508000]=0x34831106
[   24.912408] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912445] drivers/pci/access.c:93 Read 32 bits [0xfd508004]=0x100546
[   24.912454] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912490] drivers/pci/access.c:93 Read 32 bits [0xfd508008]=0xc033001
[   24.912500] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912537] drivers/pci/access.c:93 Read 32 bits [0xfd50800c]=0x10
[   24.912546] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912583] drivers/pci/access.c:93 Read 32 bits [0xfd508010]=0xc0000004
[   24.912592] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912629] drivers/pci/access.c:93 Read 32 bits [0xfd508014]=0x0
[   24.912638] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912675] drivers/pci/access.c:93 Read 32 bits [0xfd508018]=0x0
[   24.912684] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912721] drivers/pci/access.c:93 Read 32 bits [0xfd50801c]=0x0
[   24.912730] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912766] drivers/pci/access.c:93 Read 32 bits [0xfd508020]=0x0
[   24.912775] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912812] drivers/pci/access.c:93 Read 32 bits [0xfd508024]=0x0
[   24.912820] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912857] drivers/pci/access.c:93 Read 32 bits [0xfd508028]=0x0
[   24.912866] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912903] drivers/pci/access.c:93 Read 32 bits [0xfd50802c]=0x34831106
[   24.912912] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912948] drivers/pci/access.c:93 Read 32 bits [0xfd508030]=0x0
[   24.912957] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.912994] drivers/pci/access.c:93 Read 32 bits [0xfd508034]=0x80
[   24.913007] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.913050] drivers/pci/access.c:93 Read 32 bits [0xfd508038]=0x0
[   24.913059] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   24.913096] drivers/pci/access.c:93 Read 32 bits [0xfd50803c]=0x13e
[   25.123639] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.123707] drivers/pci/access.c:93 Read 32 bits [0xfd508040]=0x0
[   25.123719] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.123757] drivers/pci/access.c:93 Read 32 bits [0xfd508044]=0x100
[   25.123767] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.123804] drivers/pci/access.c:93 Read 32 bits [0xfd508048]=0x419f3009
[   25.123813] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.123850] drivers/pci/access.c:93 Read 32 bits [0xfd50804c]=0x4
[   25.123860] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.123896] drivers/pci/access.c:93 Read 32 bits [0xfd508050]=0x138a1
[   25.123906] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.123942] drivers/pci/access.c:93 Read 32 bits [0xfd508054]=0x0
[   25.123951] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.123988] drivers/pci/access.c:93 Read 32 bits [0xfd508058]=0x0
[   25.123996] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124033] drivers/pci/access.c:93 Read 32 bits [0xfd50805c]=0x34831106
[   25.124043] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124079] drivers/pci/access.c:93 Read 32 bits [0xfd508060]=0x2030
[   25.124089] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124126] drivers/pci/access.c:93 Read 32 bits [0xfd508064]=0x0
[   25.124134] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124171] drivers/pci/access.c:93 Read 32 bits [0xfd508068]=0x0
[   25.124180] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124217] drivers/pci/access.c:93 Read 32 bits [0xfd50806c]=0x0
[   25.124226] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124262] drivers/pci/access.c:93 Read 32 bits [0xfd508070]=0x0
[   25.124271] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124308] drivers/pci/access.c:93 Read 32 bits [0xfd508074]=0x0
[   25.124316] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124353] drivers/pci/access.c:93 Read 32 bits [0xfd508078]=0x30008
[   25.124362] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124399] drivers/pci/access.c:93 Read 32 bits [0xfd50807c]=0x18000001
[   25.124409] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124445] drivers/pci/access.c:93 Read 32 bits [0xfd508080]=0x89c39001
[   25.124454] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124491] drivers/pci/access.c:93 Read 32 bits [0xfd508084]=0x0
[   25.124500] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124536] drivers/pci/access.c:93 Read 32 bits [0xfd508088]=0x0
[   25.124545] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124582] drivers/pci/access.c:93 Read 32 bits [0xfd50808c]=0x0
[   25.124591] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124628] drivers/pci/access.c:93 Read 32 bits [0xfd508090]=0x85c405
[   25.124637] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124673] drivers/pci/access.c:93 Read 32 bits [0xfd508094]=0xfffffffc
[   25.124683] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124719] drivers/pci/access.c:93 Read 32 bits [0xfd508098]=0x0
[   25.124728] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124765] drivers/pci/access.c:93 Read 32 bits [0xfd50809c]=0x6540
[   25.124774] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124811] drivers/pci/access.c:93 Read 32 bits [0xfd5080a0]=0x0
[   25.124820] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124856] drivers/pci/access.c:93 Read 32 bits [0xfd5080a4]=0x0
[   25.124865] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124902] drivers/pci/access.c:93 Read 32 bits [0xfd5080a8]=0x0
[   25.124910] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124947] drivers/pci/access.c:93 Read 32 bits [0xfd5080ac]=0x0
[   25.124956] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.124992] drivers/pci/access.c:93 Read 32 bits [0xfd5080b0]=0x0
[   25.125001] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125037] drivers/pci/access.c:93 Read 32 bits [0xfd5080b4]=0x0
[   25.125046] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125083] drivers/pci/access.c:93 Read 32 bits [0xfd5080b8]=0x0
[   25.125091] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125128] drivers/pci/access.c:93 Read 32 bits [0xfd5080bc]=0x0
[   25.125137] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125174] drivers/pci/access.c:93 Read 32 bits [0xfd5080c0]=0x2000
[   25.125183] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125219] drivers/pci/access.c:93 Read 32 bits [0xfd5080c4]=0x20010
[   25.125228] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125265] drivers/pci/access.c:93 Read 32 bits [0xfd5080c8]=0x8001
[   25.125274] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125310] drivers/pci/access.c:93 Read 32 bits [0xfd5080cc]=0x192810
[   25.125319] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125356] drivers/pci/access.c:93 Read 32 bits [0xfd5080d0]=0x65c12
[   25.125365] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125401] drivers/pci/access.c:93 Read 32 bits [0xfd5080d4]=0x10120043
[   25.125410] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125447] drivers/pci/access.c:93 Read 32 bits [0xfd5080d8]=0x0
[   25.125456] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125492] drivers/pci/access.c:93 Read 32 bits [0xfd5080dc]=0x0
[   25.125501] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125538] drivers/pci/access.c:93 Read 32 bits [0xfd5080e0]=0x0
[   25.125547] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125583] drivers/pci/access.c:93 Read 32 bits [0xfd5080e4]=0x0
[   25.125592] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125629] drivers/pci/access.c:93 Read 32 bits [0xfd5080e8]=0x12
[   25.125638] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125674] drivers/pci/access.c:93 Read 32 bits [0xfd5080ec]=0x0
[   25.125683] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125720] drivers/pci/access.c:93 Read 32 bits [0xfd5080f0]=0x0
[   25.125729] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125765] drivers/pci/access.c:93 Read 32 bits [0xfd5080f4]=0x10022
[   25.125774] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125811] drivers/pci/access.c:93 Read 32 bits [0xfd5080f8]=0x0
[   25.125820] drivers/pci/controller/pcie-brcmstb.c:720 Write 32 bits [0xfd509000]=0x100000
[   25.125857] drivers/pci/access.c:93 Read 32 bits [0xfd5080fc]=0x0
[   47.974133] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   47.974140] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   47.990137] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   47.990155] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.006138] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.006144] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.022141] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.022153] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.038143] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.038149] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.054145] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.054151] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.070149] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.070164] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.086150] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.086155] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.102151] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.102156] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.118158] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.118169] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.134159] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.134171] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.150158] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.150162] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.166162] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.166174] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.182164] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.182171] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.198165] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.198170] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.214168] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.214179] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.230170] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.230180] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.246173] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.246183] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.262175] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.262181] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.278177] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.278188] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.294180] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.294186] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.310182] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.310193] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.326185] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.326201] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.342187] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.342194] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.358188] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.358195] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.374191] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.374204] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.390193] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.390198] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.406195] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.406202] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.422198] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.422208] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.438200] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.438204] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.454203] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.454209] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.470205] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.470213] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.486209] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.486222] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.502210] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.502216] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.518213] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.518223] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.534215] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.534222] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.550216] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.550227] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.566219] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.566226] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.582220] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.582226] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.598223] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.598234] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.614225] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.614232] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.630227] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.630233] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.646231] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.646241] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.662234] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.662248] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.678235] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.678241] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.966276] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.966282] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.982279] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.982290] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   48.998280] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   48.998286] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.014284] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.014291] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.030285] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.030302] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.238314] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.238320] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.254317] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.254322] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.270319] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.270328] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.286321] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.286328] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.462348] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.462353] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.542359] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.542363] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.734387] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.734398] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.750388] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.750393] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   49.766389] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   49.766393] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   52.357763] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   52.357776] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   52.453780] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   52.453800] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   52.685813] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   52.685828] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   52.757821] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   52.757832] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   52.869837] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   52.869846] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   52.941848] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   52.941861] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   53.213886] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   53.213899] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   53.261893] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   53.261901] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   53.525931] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   53.525938] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   53.621946] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   53.621959] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   53.989996] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   53.990001] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.094012] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.094022] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.174027] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.174040] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.310046] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.310060] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.414058] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.414066] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.478067] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.478072] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.558078] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.558085] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.670094] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.670100] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.822119] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.822132] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   54.918130] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   54.918141] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   55.198169] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   55.198174] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   55.286182] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   55.286188] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   55.446205] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   55.446210] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   55.534217] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   55.534223] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   56.286327] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   56.286357] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   56.358341] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   56.358358] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.351481] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.351498] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.367484] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.367497] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.383482] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.383490] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.399486] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.399494] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.415505] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.415545] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.431497] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.431515] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.447493] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.447499] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.463504] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.463526] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.479511] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.479564] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.559517] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.559539] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.575513] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.575531] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.591516] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.591537] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.607519] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.607533] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.623518] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.623524] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.639519] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.639525] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.655527] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.655543] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.671526] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.671541] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.687530] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.687551] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.767542] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.767560] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.783544] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.783564] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.799581] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.799590] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.815556] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.815594] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.831552] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.831577] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.863559] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.863588] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.911559] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.911582] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.927564] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.927581] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.943587] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.943687] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.959567] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.959586] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.975568] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.975585] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   57.991573] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   57.991590] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.007574] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.007594] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.023575] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.023594] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.039582] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.039606] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.055582] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.055602] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.071582] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.071590] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.087585] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.087599] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.103587] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.103607] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.119599] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.119640] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.199600] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.199614] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.215603] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.215619] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.231605] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.231622] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.295613] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.295627] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.311616] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.311632] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.327623] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.327640] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.343623] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.343638] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   58.407630] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   58.407645] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   63.416346] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   63.416352] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   63.496359] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   63.496371] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   64.888558] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   64.888566] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   64.904560] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   64.904567] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   64.920563] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   64.920576] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   64.936565] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   64.936581] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   64.952567] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   64.952581] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   64.968570] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   64.968583] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   65.000573] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   65.000579] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   65.208604] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   65.208614] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   65.224606] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   65.224612] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1
[   65.240608] drivers/pci/controller/pcie-brcmstb.c:491 Read 32 bits [0xfd504500]=0x1
[   65.240615] drivers/pci/controller/pcie-brcmstb.c:524 Write 32 bits [0xfd504508]=0x1


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
docker start -i rpikernel

git reset --hard HEAD; git clean -fdx
git grep -l '\(read\|write\)l' | grep '\.c$' | while read file; do if ! grep -q 'pete_\(read\|write\)l' "${file}"; then echo "processing ${file}..."; git checkout "${file}"; cat "${file}" | sed 's/readl(/pete_&/g' | sed 's/writel(/pete_&/g' | sed 's/_pete_readl/_readl/g' | sed 's/_pete_writel/_writel/g' > y; cat y | grep -n 'pete_\(read\|write\)l' | sed 's/:.*//' | while read line; do cat y | sed "${line}s%pete_readl(%&\"${file}:${line}\", %g" | sed "${line}s%pete_writel(%&\"${file}:${line}\", %g" > x; mv x y; done; mv y "${file}"; fi; done

export KERNEL=kernel8 # examples online didn't export, but I have no idea how it reaches make subprocess if not exported
make bcm2711_defconfig
sed -i 's/^\(CONFIG_LOCALVERSION=.*\)"/\1-pmoore"/' .config
sed -i 's/-pmoore-pmoore/-pmoore/' .config
sed -i 's/^# CONFIG_WERROR is not set/CONFIG_WERROR=y/' .config
# sed -i 's/^\(CONFIG_LOG_BUF_SHIFT=\).*/\118/' .config  # (note, this sets the _default_ kernel ring buffer size when an explicit value is not specified in /boot/cmdline.txt - so probably better to just specify in /boot/cmdline.txt instead, and leave the default settings alone)
make -j8 Image.gz

make drivers/pci/controller/pcie-brcmstb.i


/boot/cmdline.txt: log_buf_len=4M (log-buf-len=4M should also work)
```
