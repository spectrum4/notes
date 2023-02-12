# PCIe initialisation steps, Raspberry Pi 400

Entry point: https://github.com/raspberrypi/linux/blob/d186ba2499812b3fa0636fdbe8a01edf2cccba0e/drivers/pci/controller/pcie-brcmstb.c#L1250


1. set bit 1 of register [0xfd509210]
1. sleep for 100-200 microseconds
1. clear bit 1 or [0xfd509210]
1. clear bit 27 of [0xfd504204]
1. sleep for 100-200 microseconds
1. set bits 7, 10, 12, 13 and clear bits 20, 21 of [0xfd504008]
