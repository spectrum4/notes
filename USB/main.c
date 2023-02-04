#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <sys/mman.h>

#define RPI_PCIE_PCI_ADDR   0xf8000000UL
#define RPI_PCIE_CPU_ADDR   0x600000000UL
#define RPI_PCIE_ADDR_SIZE  0x4000000UL

#define RPI_PCIE_REG_ECAM               0x0
#define RPI_PCIE_REG_ID                 0x043c
#define RPI_PCIE_REG_MEM_PCI_LO         0x400c
#define RPI_PCIE_REG_MEM_PCI_HI         0x4010
#define RPI_PCIE_REG_STATUS             0x4068
#define RPI_PCIE_REG_REV                0x406c
#define RPI_PCIE_REG_MEM_CPU_LO         0x4070
#define RPI_PCIE_REG_MEM_CPU_HI_START   0x4080
#define RPI_PCIE_REG_MEM_CPU_HI_END     0x4084
#define RPI_PCIE_REG_DEBUG              0x4204
#define RPI_PCIE_REG_INTMASK            0x4310
#define RPI_PCIE_REG_INTCLR             0x4314
#define RPI_PCIE_REG_CFG_INDEX          0x9000
#define RPI_PCIE_REG_INIT               0x9210

typedef struct
{
    uint16_t    vid;
    uint16_t    did;
    uint16_t    command;
    uint16_t    status;
    uint8_t     revision;
    uint8_t     prog;
    uint8_t     subclass;
    uint8_t     class;
    uint8_t     cache_line_size;
    uint8_t     latency_timer;
    uint8_t     header_type;
    uint8_t     bist;
} pci_header_common_t;

typedef struct
{
    pci_header_common_t common;
    uint32_t            bar[6];
} pci_header_0_t;

typedef struct
{
    pci_header_common_t common;
    uint32_t            bar[2];
    uint8_t             primary_bus;
    uint8_t             secondary_bus;
    uint8_t             subordinate_bus;
    uint8_t             secondary_latency_timer;
} pci_header_1_t;

static inline volatile uint32_t *
reg_addr(volatile uint32_t * const regs, uint32_t const off)
{
    return &regs[off / sizeof(uint32_t)];
}

static inline uint32_t
read_reg(volatile uint32_t * const regs, uint32_t const off)
{
    return *reg_addr(regs, off);
}

static inline void
write_reg(volatile uint32_t * const regs, uint32_t off, uint32_t const value)
{
    *reg_addr(regs, off) = value;
}

static inline uint32_t *
map_regs(uintptr_t addr, size_t size)
{
    return mmap(0, size, PROT_READ | PROT_WRITE | PROT_NOCACHE,
                MAP_SHARED | MAP_PHYS,
                NOFD, addr);
}

int
main(int argc, char **argv)
{
    volatile uint32_t * const   pcie_regs = map_regs(0xfd500000, 0x9310);
    if (pcie_regs == MAP_FAILED) {
        perror("mmap");
        return 1;
    }

    // Reset controller.
    uint32_t    init = read_reg(pcie_regs, RPI_PCIE_REG_INIT);
    init |= 0x3;
    write_reg(pcie_regs, RPI_PCIE_REG_INIT, init);
    init = read_reg(pcie_regs, RPI_PCIE_REG_INIT);

    usleep(1000);

    init = read_reg(pcie_regs, RPI_PCIE_REG_INIT);
    init &= ~0x2;
    write_reg(pcie_regs, RPI_PCIE_REG_INIT, init);
    init = read_reg(pcie_regs, RPI_PCIE_REG_INIT);

    uint32_t    rev = read_reg(pcie_regs, RPI_PCIE_REG_REV);
    printf("Rev=%x\n", rev);

    // Clear and mask interrupts.
    write_reg(pcie_regs, RPI_PCIE_REG_INTCLR, 0xffffffff);
    write_reg(pcie_regs, RPI_PCIE_REG_INTMASK, 0xffffffff);

    // Take controller out of reset.
    init = read_reg(pcie_regs, RPI_PCIE_REG_INIT);
    init &= ~0x1;
    write_reg(pcie_regs, RPI_PCIE_REG_INIT, init);

    // Wait for link to become active.
    uint32_t    status = read_reg(pcie_regs, RPI_PCIE_REG_STATUS);
    for (unsigned i = 0; i < 100; i++) {
        if ((status & 0x30) == 0x30) {
            break;
        }
        usleep(1000);
        status = read_reg(pcie_regs, RPI_PCIE_REG_STATUS);
    }

    if ((status & 0x30) != 0x30) {
        printf("PCIe link not ready (status=%x)\n", status);
        return 1;
    }

    if ((status & 0x80) != 0x80) {
        printf("PCIe is not in RC mode (status=%x)\n", status);
        return 1;
    }

    printf("PCIe link ready (status=%x)\n", status);

    uint32_t    ccode = read_reg(pcie_regs, RPI_PCIE_REG_ID);
    printf("Class code %x\n", ccode);
    if ((ccode & 0xffffff) != 0x060400) {
        ccode = (ccode & ~0xffffff) | 0x060400;
        printf("Changing to %x\n", ccode);
        write_reg(pcie_regs, RPI_PCIE_REG_ID, ccode);
    }

    // Set up the PCI address, split into two 32-bit registers.
    write_reg(pcie_regs, RPI_PCIE_REG_MEM_PCI_LO,
              (uint32_t)RPI_PCIE_PCI_ADDR);
    write_reg(pcie_regs, RPI_PCIE_REG_MEM_PCI_HI,
              (uint32_t)(RPI_PCIE_PCI_ADDR >> 32));

    // Set up the CPU addresses.
    // The low register holds the bottom part of the start and end addresses as
    // two 12-bit values expressed in megabytes:
    // | low_end |  0  | low_start | 0 |
    // | 31    20|   16|          4|  0|
    // Note that the end address gets truncated at the megabyte boundary, so
    // 0x1000000 bytes will become 0xf megabytes.
    // There are two high registers for holding the top 32-bits of the start and
    // end addresses, respectively.
    // Of course, this is all speculation in the absence of an official
    // datasheet.
    uint64_t    cpu_addr_start = RPI_PCIE_CPU_ADDR;    // 0x600000000
    uint64_t    cpu_addr_end = RPI_PCIE_CPU_ADDR + RPI_PCIE_ADDR_SIZE; // 0x600000000 + 0x4000000 = 0x604000000

    uint32_t    cpu_addr_low =
        ((cpu_addr_start >> 16) & 0xffff)
        | (((cpu_addr_end >> 20) - 1) << 20);   //  0x03f00000

    write_reg(pcie_regs, RPI_PCIE_REG_MEM_CPU_LO, cpu_addr_low);   // [0xfd504070] = 0x03f00000
    write_reg(pcie_regs, RPI_PCIE_REG_MEM_CPU_HI_START,
              cpu_addr_start >> 32); // [0xfd504080] = 0x6
    write_reg(pcie_regs, RPI_PCIE_REG_MEM_CPU_HI_END,
              cpu_addr_end >> 32); // [0xfd504084] = 0x6


    // Device on 0:0:0 should be a bridge.
    volatile pci_header_1_t  *bridge =
        (volatile void *)reg_addr(pcie_regs, RPI_PCIE_REG_ECAM);
    printf("VID/DID: %.4x/%.4x Type: %u\n", bridge->common.vid,
           bridge->common.did,
           bridge->common.header_type);
    if (bridge->common.header_type != 1) {
        printf("Not a bridge\n");
        return 1;
    }

    // Configure secondary and subordinate device numbers.
    bridge->secondary_bus = 1;
    bridge->subordinate_bus = 1;

    // Set up the configuration space for reading from 1:0:0.
    write_reg(pcie_regs, RPI_PCIE_REG_CFG_INDEX, 1 << 20);

    // Read device configuration for 1:0:0.
    // Should be the XHCI Controller.
    volatile pci_header_0_t *device
        = (volatile void *)reg_addr(pcie_regs,
                                    RPI_PCIE_REG_ECAM + 0x8000);
    printf("VID/DID: %.4x/%.4x Type: %u\n", device->common.vid,
           device->common.did,
           device->common.header_type);
           
    return 0;
}
