# Detecting key presses on rpi400 with circle library

Rene Stange's C++ Circle library provides libraries for writing bare metal C++
applications on Raspberry Pi devices.  It comes with a [sample
program](https://github.com/rsta2/circle/blob/master/sample/08-usbkeyboard/kernel.cpp)
for reading from a USB keyboard.

This runs successfully on a rpi400 device, and therefore contains all of the
elements required in order to interpret key presses on this device.  This
document is an attempt to unravel how it works, in order that I can develop my
own keyboard routines for the Spectrum +4 project in assembly.

I have compiled the code and output the generated assembly, to aid the
demystification process (see generate-dissassembly.sh script).

The entry point is
[`_start`](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/startup64.S#L77)
assembly routine. This performs some basic initialisation to get from EL3 to
EL1, set up stacks, exception table etc. Nothing here that Spectrum +4 needs,
as these parts are already developed. There is code for starting up additional
cores, but we're not supporting this on Spectrum +4 at the moment, so we'll
ignore it. It appears to be optional, anyway.

At the end, we
[break](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/startup64.S#L97)
to `sysinit` function.  That takes us
[here](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/sysinit.cpp#L187).
Both
[regular](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/include/circle/synchronize64.h#L46)
and
[fast](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/include/circle/synchronize64.h#L51)
interrupts are enabled. After this, [bss is
cleared](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/sysinit.cpp#L208-L211)
(pretty standard), a check is made that `MEM_KERNEL_END` fits inside the bss
section otherwise system is halted. After this
[`MachineInfo`](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/machineinfo.cpp#L144-L243)
and
[`Memory`](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/memory.cpp#L48-L144)
variables are declared which will eventually hold information about the
raspberry pi version, memory, peripherals, etc. Afterwards .dtb files on the
boot media are loaded to update `MachineInfo` with additional information.
Next, [static constructors are
called](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/sysinit.cpp#L246-L252),
if any are registered. I can't seem to find any registered (the
[circle.ld](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/circle.ld#L23-L29)
file keeps `.init_array*` sections between `__init_start` and `__init_end`) so
probably this is just so external code that uses cirlce can register static
constructors if required. However, this led me to the [memory map
docs](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/doc/memorymap.txt#L193-L238),
which will probably be useful later.

Finally, we call
[`MAINPROC`](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/sysinit.cpp#L255),
(which defaults to
[`main`](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/include/circle/sysconfig.h#L453-L463))
before halting/rebooting.

The `main` method is found
[here](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/sample/08-usbkeyboard/main.cpp#L23).
This creates a CKernel instance, and calls Initialize on it. If successful, it
then calls Run method.

The CKernel constructor is
[here](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/sample/08-usbkeyboard/kernel.cpp#L33).
This constructs objects for the various subsystems, and most importantly, one of these is the
[USB Host Controller
Interface](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/sample/08-usbkeyboard/kernel.cpp#L37).
This is declared
[here](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/sample/08-usbkeyboard/kernel.h#L72)
as `CUSBHCIDevice` which maps to the
[`CXHCIDevice`](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/include/circle/usb/usbhcidevice.h#L31)
class whose constructor is found
[here](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/usb/xhcidevice.cpp#L38).

The Initialize call of the CKernel instance [configures the
systems](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/sample/08-usbkeyboard/kernel.cpp#L51-L92)
that were created in the constructor:
* screen
* serial driver
* logger
* interrupt handling
* timer
* USB host controller interface.

Interrupt initialization is managed in
[interruptgic.cpp](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/interruptgic.cpp#L109-L174)
on rpi4.

# CXHCIDevice

The first entry in the initialization list is just a boolean for whether plug
and play is enabled. This is just passed through and there is no additional
logic. The second entry in the initialization list is for the interrupt system
(`CInterruptSystem m_pInterruptSystem`). The constructor
[here](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/lib/interruptgic.cpp#L89-L98)
initialises the [data
structures](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/include/circle/interrupt.h#L66-L67)
for the
[256](https://github.com/rsta2/circle/blob/c21f2efdad86c1062f255fbf891135a2a356713e/include/circle/bcm2711int.h#L64)
interrupt lines.

# Notes

## Debugging

```diff
#include <circle/logger.h>
...
static const char From[] = "foo-subsystem";
...
+       LOGDBG ("Logging my first message");
+       LOGDBG ("Circle version: %s", Version);
+       LOGDBG ("Machine name: %s", MachineInfo.GetMachineName());
+       LOGDBG ("Memory size: %u", Memory.GetMemSize());
```

Formatting primitives: see lib/string.cpp
  * `%u`
  * `%x`
  * `%i`
  * `%l`
  * `%s`
  * `%f`

Compiling:

```
cd lib
make clean
make
cd ../samples/08-usbkeyboard
make clean
make
```

Debug settings:

```
$ git grep '#ifdef.*DEBUG' | sed 's/.*:#ifdef //' | sort -u
DEBUG
DEBUG_CLICK
EMMC_DEBUG
EMMC_DEBUG2
HDMI_DEBUG
HEAP_DEBUG
NDEBUG
PAGE_DEBUG
RTO_DEBUG
TCP_DEBUG
USB_GADGET_DEBUG
VCOS_BLOCKPOOL_DEBUGGING
XHCI_DEBUG
XHCI_DEBUG2
```

## ARM registers that are updated

The USB example on rpi4 updates the following ARM registers:

arm stub

```
* l2ctlr_el1:                      (set bits 1, 5) [5] [1]
                                                  // => L2 Data RAM latency [2:0] = 0b010 = 2 => 3 cycles
                                                  // => L2 Data RAM setup [5] = 1 => 1 cycle
* cntfrq_el0:   0x000000000337f980 (54 000 000) ... set in armstub - clock frequency, i.e. 54MHz [63:0]
* cntvoff_el2:  0x0000000000000000 (virtual offset to physical timer) [63:0]
* cptr_el3:     0x0000000000000000 (enable floating point/SIMD) [63:0]
* scr_el3:      0x0000000000000531 [63:0]

                                                  // => NS [0] = 1 => Non-secure security state
                                                  // => IRQ [1] = 0 => Exceptions in IRQ mode (not monitor mode)
                                                  // => FIQ [2] = 0 => FIQs in FIQ mode (not monitor mode)
                                                  // => EA [3] = 0 => External aborts in Abort mode (not monitor mode)
                                                  // => FW / RES1 [4] = 1 => seems to be RES1 but see CPSR.F and HCR.FMO
                                                  // => AW / RES1 [5] = 1 => seems to be RES1 but see CPSR.A and HCR.AMO
                                                  // => nET / RES0 [6] = 0 => RES0
                                                  // => SCD / SMD [7] = 0 => SMC works from privileged modes
                                                  // => HCE [8] = 1 => HVC enabled in EL1 and EL2 and performs a Hyp Call
                                                  // => SIF [9] = 0 => Secure state instruction fetches from Non-secure memory permitted
                                                  // => RES0 / RW [10] = 1 => EL2 uses aarch64
                                                  // => RES0 / ST [11] = 0 => no traps for accesses to the Counter-timer Physical Secure timer registers





* vbar_el3:     0x0000000000070000 [63:0]
* cpuectlr_el1  0x0000000000000040 (SMPEN: Enables data coherency with other cores in the cluster) [63:0]
* sctlr_el2     0x0000000030c50830 [63:0]
* spsr_el3      0x00000000000003c9 [63:0]
```

kernel startup

```
* vbar_el2:     0x00000000000af800 [63:0]
* cnthctl_el2:  0x0000000000000003 (enable EL1 and EL0 access to physical timer registers CNTP_CTL_EL0, CNTP_CVAL_EL0, CNTP_TVAL_EL0, CNTPCT_EL0 and CNTPCTSS_EL0) - [1:0]
* cntvoff_el2:  0x0000000000000000 (virtual offset to physical timer) [63:0] (note, already done in arm stub)
* vpidr_el2:    0x00000000410fd083 == [midr_el1] [63:0]
* vmpidr_el2:   0x0000000080000000 == [mpidr_el1] [63:0]
* cptr_el2:     0x00000000000033ff (do not trap FP/SIMD operations) [63:0]
* hstr_el2:     0x0000000000000000 [63:0]
* cpacr_el1:    0x0000000000300000 (do not trap FP/SIMD operations in EL0/EL1) [63:0]
* hcr_el2:      0x0000000080000000 [63:0]
* sctlr_el1:    0x0000000030d00800 [63:0] (reset value is 0x00c50838)
* spsr_el2:     0x00000000000003c4 [63:0]
* vbar_el1:     0x00000000000af800 [63:0]
```

timer

```
* cntp_ctl_el0: 0x0000000000000001 (timer init - enables the timer) [0]
* cntp_cval_el0                    (time of next scheduled interrupt) [63:0]
```

enable mmu

```
* mair_el1:     0x00000000000004ff [63:0]
* ttbr0_el1:    0x0000000007000000 page table address [63:0]
* tcr_el1:      0x000000010080751c [34:32] [23] [22] [15:14] [13:12] [11:10] [9:8] [7] [5:0]

                                                  // => T0SZ [5:0] = 0b011100 = 28 => region size = 2^(64-28) = 2^36 bytes = 64 GB
                                                  // => RES0 [6] = <unchanged>
                                                  // => EPD0 [7] = 0 => perform walk on a miss
                                                  // => IRGN0 [9:8] = 0b01 => Normal memory, Inner Write-Back Read-Allocate Write-Allocate Cacheable.
                                                  // => ORGN0 [11:10] = 0b01 => Normal memory, Outer Write-Back Read-Allocate Write-Allocate Cacheable.
                                                  // => SH0 [13:12] = 0b11 => Inner Shareable
                                                  // => TG0 [15:14] = 0b01 => Granule size 64KB
                                                  // => T1SZ [21:16] = <unchanged>
                                                  // => A1 [22] = 0 => TTBR0_EL1.ASID defines the ASID
                                                  // => EPD1 [23] = 1 => A TLB miss on an address that is translated using TTBR1_EL1 generates a Translation fault. No translation table walk is performed
                                                  // => IRGN1 [25:24] = <unchanged>
                                                  // => ORGN1 [27:26] = <unchanged>
                                                  // => SH1 [29:28] = <unchanged>
                                                  // => TG1 [31:30] = <unchanged> (Granule size for TTBR1_EL1)
                                                  // => IPS [34:32] = 1 => Intermediate Physical Address size = 36 bits, 64GB.


* sctlr_el1:    0x0000000030d01805 [19] [12] [2] [1] [0]
* sctlr_el1:    0x0000000030d00801 [19] [12] [2] [1] [0]
                                                  // => WXN [19] = 0 (Regions with write permission are not forced to be "eXecute Never")
                                                  // => I [12] = 1 (Enable instruction cache)
                                                  // => C [2] = 1 (Data and unified caches enabled)
                                                  // => A [1] = 0 (Alignment fault checking disabled)
                                                  // => M [0] = 1 (EL1 and EL0 stage 1 MMU enabled)
```

hvc stub

```
* spsr_el2:     0x---------------9 [3:0] => 0b1001

                                                  // => M [3:0] = 0b1001 AArch64 Exception level and selected Stack Pointer: EL2 with SP_EL2 (EL2h)
```

kernel _start


CTimer::~CTimer() # Destructor
```
   a625c:    d2800001     mov    x1, #0x0                       // #0
   a6260:    d51be221     msr    cntp_ctl_el0, x1
```


CTimer::InterruptHandler()
```
   a6c24:    d53be241     mrs    x1, cntp_cval_el0
   a6c28:    b9400800     ldr    w0, [x0, #8]
   a6c2c:    8b010000     add    x0, x0, x1
   a6c30:    d51be240     msr    cntp_cval_el0, x0
```

CTimer::Initialize()
```
   a6e0c:    d53be001     mrs    x1, cntfrq_el0
   a6e10:    d28b8520     mov    x0, #0x5c29                    // #23593
   a6e14:    f2b851e0     movk    x0, #0xc28f, lsl #16
   a6e18:    f2c51ea0     movk    x0, #0x28f5, lsl #32
   a6e1c:    f2f1eb80     movk    x0, #0x8f5c, lsl #48
   a6e20:    d291eb82     mov    x2, #0x8f5c                    // #36700
   a6e24:    f2beb842     movk    x2, #0xf5c2, lsl #16
   a6e28:    9b007c20     mul    x0, x1, x0
   a6e2c:    f2cb8502     movk    x2, #0x5c28, lsl #32
   a6e30:    f2e051e2     movk    x2, #0x28f, lsl #48
   a6e34:    93c00800     ror    x0, x0, #2
   a6e38:    eb02001f     cmp    x0, x2
   a6e3c:    54000348     b.hi    a6ea4 <CTimer::Initialize()+0xc4>  // b.pmore
   a6e40:    d29eb860     mov    x0, #0xf5c3                    // #62915
   a6e44:    f2ab8500     movk    x0, #0x5c28, lsl #16
   a6e48:    d342fc21     lsr    x1, x1, #2
   a6e4c:    f2d851e0     movk    x0, #0xc28f, lsl #32
   a6e50:    f2e51ea0     movk    x0, #0x28f5, lsl #48
   a6e54:    9bc07c21     umulh    x1, x1, x0
   a6e58:    d342fc21     lsr    x1, x1, #2
   a6e5c:    b9000a61     str    w1, [x19, #8]
   a6e60:    d53be020     mrs    x0, cntpct_el0
   a6e64:    8b214001     add    x1, x0, w1, uxtw
   a6e68:    d51be241     msr    cntp_cval_el0, x1
   a6e6c:    d2800034     mov    x20, #0x1                       // #1
   a6e70:    d51be234     msr    cntp_ctl_el0, x20
```

CMemorySystem::Destructor()
```
   a8dc8:    d5381000     mrs    x0, sctlr_el1
   a8dcc:    928000a1     mov    x1, #0xfffffffffffffffa        // #-6
   a8dd0:    8a010000     and    x0, x0, x1
   a8dd4:    d5181000     msr    sctlr_el1, x0
   a8dd8:    d5033f9f     dsb    sy
   a8ddc:    d5033fdf     isb
   a8de0:    9400017c     bl    a93d0 <CleanDataCache>
   a8de4:    9400011f     bl    a9260 <InvalidateDataCache>
   a8de8:    d508871f     tlbi    vmalle1
   a8dec:    d5033f9f     dsb    sy
   a8df0:    d5033fdf     isb
```

CMemorySystem::EnableMMU()
```
   a8f20:    d2809fe1     mov    x1, #0x4ff                     // #1279
   a8f24:    d518a201     msr    mair_el1, x1
   a8f28:    f9419400     ldr    x0, [x0, #808]
   a8f2c:    b4000360     cbz    x0, a8f98 <CMemorySystem::EnableMMU()+0x88>
   a8f30:    940001b4     bl    a9600 <CTranslationTable::GetBaseAddress() const>
   a8f34:    d5182000     msr    ttbr0_el1, x0
   a8f38:    d5382040     mrs    x0, tcr_el1
   a8f3c:    929ff7e2     mov    x2, #0xffffffffffff0040        // #-65472
   a8f40:    f2bff7e2     movk    x2, #0xffbf, lsl #16
   a8f44:    f2dfff02     movk    x2, #0xfff8, lsl #32
   a8f48:    d28ea381     mov    x1, #0x751c                    // #29980
   a8f4c:    f2a01001     movk    x1, #0x80, lsl #16
   a8f50:    8a020000     and    x0, x0, x2
   a8f54:    f2c00021     movk    x1, #0x1, lsl #32
   a8f58:    aa010000     orr    x0, x0, x1
   a8f5c:    d5182040     msr    tcr_el1, x0
   a8f60:    d5381000     mrs    x0, sctlr_el1
   a8f64:    92800042     mov    x2, #0xfffffffffffffffd     //   (bit 1)
   a8f68:    f2bffee2     movk    x2, #0xfff7, lsl #16    //   (bit 19)
   a8f6c:    d28200a1     mov    x1, #0x1005                    //   (bits 0, 2, 12)
   a8f70:    8a020000     and    x0, x0, x2                  //   clear bits 1, 19
   a8f74:    aa010000     orr    x0, x0, x1                  //   set bits 0, 2, 12
   a8f78:    d5181000     msr    sctlr_el1, x0
```

IRQStub
```
   af8cc:    d518403d     msr    elr_el1, x29
   af8d0:    d518401e     msr    spsr_el1, x30
```

HVCStub
```
   af9a0:    d53c4000     mrs    x0, spsr_el2
   af9a4:    927cec00     and    x0, x0, #0xfffffffffffffff0
   af9a8:    d2800121     mov    x1, #0x9                       // #9
   af9ac:    aa010000     orr    x0, x0, x1
   af9b0:    d51c4000     msr    spsr_el2, x0
```


Spectrum +4 currently updates the following ARM registers:

* `elr_el2`
* `elr_el3`
* `hcr_el2`
* `mair_el1`
* `scr_el3`
* `sctlr_el1`
* `spsr_el2`
* `spsr_el3`
* `tcr_el1`
* `ttbr0_el1`
* `ttbr1_el1`
* `vbar_el1`

And updates to the following registers should be considered:

* `cntfrq_el0`
* `cnthctl_el2`
* `cntp_ctl_el0`
* `cntp_cval_el0`
* `cntvoff_el2`
* `cpacr_el1`
* `cptr_el2`
* `cptr_el3`
* `cpuectlr_el1`
* `elr_el1`
* `hstr_el2`
* `l2ctlr_el1`
* `sctlr_el2`
* `sp_el1`
* `spsr_el1`
* `vbar_el2`
* `vbar_el3`
* `vmpidr_el2`
* `vpidr_el2`

It would also be beneficial to dump the values of all of these registers in
both projects to compare them. See
https://developer.arm.com/documentation/ddi0601/2024-09/AArch64-Registers?lang=en
for descriptions of the registers.




## Start up

arm stub

```asm
/*
 * Modified version for the Raspberry Pi 4 which allows using FIQ with Circle
 */
/*
 * Copyright (c) 2016 Raspberry Pi (Trading) Ltd.
 * Copyright (c) 2016 Stephen Warren <swarren@wwwdotorg.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the copyright holder nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
.globl _start
_start:
 /*
	 * LOCAL_CONTROL:
	 * Bit 9 clear: Increment by 1 (vs. 2).
	 * Bit 8 clear: Timer source is 19.2MHz crystal (vs. APB).
	 */
 mov x0, 0xff800000
 str wzr, [x0]
 /* LOCAL_PRESCALER; divide-by (0x80000000 / register_val) == 1 */
 mov w1, 0x80000000
 str w1, [x0, #(0xff800008 - 0xff800000)]
 /* Set L2 read/write cache latency to 3 */
 mrs x0, S3_1_C11_C0_2
 mov x1, #0x22
 orr x0, x0, x1
 msr S3_1_C11_C0_2, x0
 /* Set up CNTFRQ_EL0 */
 ldr x0, =54000000
 msr CNTFRQ_EL0, x0
 /* Set up CNTVOFF_EL2 */
 msr CNTVOFF_EL2, xzr
 /* Enable FP/SIMD */
 /* bit 10 (TFP) set to 0 */
 msr CPTR_EL3, xzr
 /* Set up SCR */
 mov x0, #((1 << (10)) | (1 << (8)) | (1 << (5)) | (1 << (4)) | (1 << (0)))
 msr SCR_EL3, x0
 /* Set up secure monitor entry and stack */
 mov x0, #0x70000
 msr VBAR_EL3, x0
 mov sp, x0
 /* Set SMPEN */
 mov x0, #(1 << (6))
 msr S3_1_C15_C2_1, x0
        bl setup_gic
 /*
	 * Set up SCTLR_EL2
	 * All set bits below are res1. LE, no WXN/I/SA/C/A/M
	 */
 ldr x0, =0x30c50830
 msr SCTLR_EL2, x0
 /* Switch to EL2 */
 mov x0, #((1 << (9)) | (1 << (8)) | (1 << (7)) | (1 << (6)) | 9)
 msr spsr_el3, x0
 adr x0, in_el2
 msr elr_el3, x0
 eret
in_el2:
 mrs x6, MPIDR_EL1
 and x6, x6, #0x3
 cbz x6, primary_cpu
 adr x5, spin_cpu0
secondary_spin:
 wfe
 ldr x4, [x5, x6, lsl #3]
 cbz x4, secondary_spin
 mov x0, #0
 b boot_kernel
primary_cpu:
 ldr w4, kernel_entry32
 ldr w0, dtb_ptr32
boot_kernel:
 mov x1, #0
 mov x2, #0
 mov x3, #0
 br x4
.ltorg
.org 0xd4
 .ascii "FIQS" /* Circle GIC code checks this for presence */
.org 0xd8
.globl spin_cpu0
spin_cpu0:
 .quad 0
.org 0xe0
.globl spin_cpu1
spin_cpu1:
 .quad 0
.org 0xe8
.globl spin_cpu2
spin_cpu2:
 .quad 0
.org 0xf0
.globl spin_cpu3
spin_cpu3:
 # Shared with next two symbols/.word
 # FW clears the next 8 bytes after reading the initial value, leaving
 # the location suitable for use as spin_cpu3
.org 0xf0
.globl stub_magic
stub_magic:
 .word 0x5afe570b
.org 0xf4
.globl stub_version
stub_version:
 .word 0
.org 0xf8
.globl dtb_ptr32
dtb_ptr32:
 .word 0x0
.org 0xfc
.globl kernel_entry32
kernel_entry32:
 .word 0x0
.org 0x100
setup_gic: // Called from secure mode - set all interrupts to group 1 and enable.
 mrs x0, MPIDR_EL1
 ldr x2, =0xff841000
 tst x0, #0x3
 b.eq 2f // primary core
 mov w0, #3 // Enable group 0 and 1 IRQs from distributor
 str w0, [x2, #0x0]
2:
 add x1, x2, #(0xff842000 - 0xff841000)
 mov w0, #0x1e7
 str w0, [x1, #0x0] // Enable group 1 IRQs from CPU interface
 mov w0, #0xff
 str w0, [x1, #0x4] // priority mask
 add x2, x2, #0x80
 mov x0, #(0x8 * 4)
 mov w1, #~0 // group 1 all the things
3:
 subs x0, x0, #4
 str w1, [x2, x0]
 b.ne 3b
 ret
.ltorg
.globl dtb_space
dtb_space:
```

startup

```asm
 .section .init
 .globl _start
_start: /* normally entered from armstub8 in EL2 after boot */
 mrs x0, CurrentEL /* check if already in EL1t mode? */
 cmp x0, #4
 beq 1f
 ldr x0, =0x0000000000308000 /* IRQ, FIQ and exception handler run in EL1h */
 msr sp_el1, x0 /* init their stack */
 ldr x0, =VectorTable /* init exception vector table for EL2 */
 msr vbar_el2, x0
 /* Initialize Generic Timers */
 mrs x0, cnthctl_el2
 orr x0, x0, #0x3 /* Enable EL1 access to timers */
 msr cnthctl_el2, x0
 msr cntvoff_el2, xzr
 /* Initilize MPID/MPIDR registers */
 mrs x0, midr_el1
 mrs x1, mpidr_el1
 msr vpidr_el2, x0
 msr vmpidr_el2, x1
 /* Disable coprocessor traps */
 mov x0, #0x33ff
 msr cptr_el2, x0 /* Disable coprocessor traps to EL2 */
 msr hstr_el2, xzr /* Disable coprocessor traps to EL2 */
 mov x0, #3 << 20
 msr cpacr_el1, x0 /* Enable FP/SIMD at EL1 */
 /* Initialize HCR_EL2 */
 mov x0, #(1 << 31) /* 64bit EL1 */
 msr hcr_el2, x0
 /* SCTLR_EL1 initialization
	 *
	 * setting RES1 bits (29,28,23,22,20,11) to 1
	 * and RES0 bits (31,30,27,21,17,13,10,6) +
	 * UCI,EE,EOE,WXN,nTWE,nTWI,UCT,DZE,I,UMA,SED,ITD,
	 * CP15BEN,SA0,SA,C,A,M to 0
	 */
 mov x0, #0x0800
 movk x0, #0x30d0, lsl #16
 msr sctlr_el1, x0
 /* Return to the EL1_SP1 mode from EL2 */
 mov x0, #0x3c4
 msr spsr_el2, x0 /* EL1_SP0 | D | A | I | F */
 adr x0, 1f
 msr elr_el2, x0
 eret
1:
 ldr x0, =((0x80000 + (2 * 0x100000)) + 0x20000) /* main thread runs in EL1t and uses sp_el0 */
 mov sp, x0 /* init its stack */
 ldr x0, =VectorTable /* init exception vector table */
 msr vbar_el1, x0
 b sysinit
```

sysinit

```cpp
void sysinit (void)
{
 asm volatile ("msr DAIFClr, #1"); // go to IRQ_LEVEL, EnterCritical() will not work otherwise
 asm volatile ("msr DAIFClr, #2"); // go to TASK_LEVEL
 // clear BSS
 extern unsigned char __bss_start;
 extern unsigned char _end;
 memset (&__bss_start, 0, &_end - &__bss_start);
 // halt, if KERNEL_MAX_SIZE is not properly set
 // cannot inform the user here
 if ((0x80000 + (2 * 0x100000)) < reinterpret_cast<uintptr> (&_end))
 {
  halt ();
 }
 CMemorySystem Memory;
 CMachineInfo MachineInfo;
 Memory.SetupHighMem ();
 // set circle_version_string[]
 CString Version;
 if ((480000 % 100))
 {
  Version.Format ("%d.%d.%d", (480000 / 10000), (480000 / 100 % 100),
           (480000 % 100));
 }
 else if ((480000 / 100 % 100))
 {
  Version.Format ("%d.%d", (480000 / 10000), (480000 / 100 % 100));
 }
 else
 {
  Version.Format ("%d", (480000 / 10000));
 }
 strcpy (circle_version_string, Version);
 CInterruptSystem InterruptSystem;
 if (!InterruptSystem.Initialize ())
 {
  error_halt (2);
 }
 // call constructors of static objects
 extern void (*__init_start) (void);
 extern void (*__init_end) (void);
 for (void (**pFunc) (void) = &__init_start; pFunc < &__init_end; pFunc++)
 {
  (**pFunc) ();
 }
 extern int main (void);
 int nResult = main ();
 if (nResult == 1)
 {
  if (IsChainBootEnabled ())
  {
   InterruptSystem.Destructor ();
   Memory.Destructor ();
   asm volatile ("msr DAIFSet, #1");
   DoChainBoot ();
  }
  reboot ();
 }
 halt ();
}
```

```cpp
void CMemorySystem::SetupHighMem (void)
{
 unsigned nRAMSize = CMachineInfo::Get ()->GetRAMSize ();
 if (nRAMSize > 1024)
 {
  u64 nHighSize = (nRAMSize - 1024) * 0x100000;
  if (nHighSize > (3 * 0x40000000UL - 1)+1 - 0x40000000UL)
  {
   nHighSize = (3 * 0x40000000UL - 1)+1 - 0x40000000UL;
  }
  m_nMemSizeHigh = (size_t) nHighSize;
  m_HeapHigh.Setup (0x40000000UL, (size_t) nHighSize, 0);
 }
}
```

```cpp
void CHeapAllocator::Setup (uintptr nBase, size_t nSize, size_t nReserve)
{
 m_pNext = (u8 *) nBase;
 m_pLimit = (u8 *) (nBase + nSize);
 m_nReserve = nReserve;
}
```

```cpp
CMemorySystem *CMemorySystem::s_pThis = 0;
CMemorySystem::CMemorySystem (boolean bEnableMMU)
: m_bEnableMMU (bEnableMMU),
 m_nMemSize (0),
 m_nMemSizeHigh (0),
 m_HeapLow ("heaplow"),
 m_HeapHigh ("heaphigh"),
 m_pTranslationTable (0)
{
 if (s_pThis != 0) // ignore second instance
 {
  return;
 }
 s_pThis = this;
 CBcmPropertyTags Tags (true);
 TPropertyTagMemory TagMemory;
 if (!Tags.GetTag (0x00010005, &TagMemory, sizeof TagMemory))
 {
  TagMemory.nBaseAddress = 0;
  TagMemory.nSize = ((512 * 0x100000) - (64 * 0x100000));
 }
 ( __builtin_expect (!!(TagMemory.nBaseAddress == 0), 1) ? ((void) 0) : assertion_failed ("TagMemory.nBaseAddress == 0", "memory64.cpp", 55));
 m_nMemSize = TagMemory.nSize;
 size_t nBlockReserve = m_nMemSize - (((((((0x80000 + (2 * 0x100000)) + 0x20000) + 0x20000 * (4 -1) + 0x8000) + 0x8000 * (4 -1)) + 2*0x100000) & ~(0x100000 -1)) + 4*0x100000) - (16 * 0x100000);
 m_HeapLow.Setup ((((((((0x80000 + (2 * 0x100000)) + 0x20000) + 0x20000 * (4 -1) + 0x8000) + 0x8000 * (4 -1)) + 2*0x100000) & ~(0x100000 -1)) + 4*0x100000), nBlockReserve, 0x40000);
 m_Pager.Setup ((((((((0x80000 + (2 * 0x100000)) + 0x20000) + 0x20000 * (4 -1) + 0x8000) + 0x8000 * (4 -1)) + 2*0x100000) & ~(0x100000 -1)) + 4*0x100000) + nBlockReserve, (16 * 0x100000));
 if (m_bEnableMMU)
 {
  m_pTranslationTable = new CTranslationTable (m_nMemSize);
  ( __builtin_expect (!!(m_pTranslationTable != 0), 1) ? ((void) 0) : assertion_failed ("m_pTranslationTable != 0", "memory64.cpp", 66));
  EnableMMU ();
  asm volatile ("isb" ::: "memory");
 }
}
```

```cpp
void CMemorySystem::EnableMMU (void)
{
 ( __builtin_expect (!!(m_bEnableMMU), 1) ? ((void) 0) : assertion_failed ("m_bEnableMMU", "memory64.cpp", 156));
 u64 nMAIR_EL1 = 0xFF << 0*8 // inner/outer write-back non-transient, allocating
                 | 0x04 << 1*8 // Device-nGnRE
                 | 0x00 << 2*8; // Device-nGnRnE
 asm volatile ("msr mair_el1, %0" : : "r" (nMAIR_EL1));
 ( __builtin_expect (!!(m_pTranslationTable != 0), 1) ? ((void) 0) : assertion_failed ("m_pTranslationTable != 0", "memory64.cpp", 163));
 asm volatile ("msr ttbr0_el1, %0" : : "r" (m_pTranslationTable->GetBaseAddress ()));
 u64 nTCR_EL1;
 asm volatile ("mrs %0, tcr_el1" : "=r" (nTCR_EL1));
 nTCR_EL1 &= ~( (7UL << 32)
        | (1 << 22)
        | (3 << 14)
        | (3 << 12)
        | (3 << 10)
        | (3 << 8)
        | (1 << 7)
        | (0x3F << 0));
 nTCR_EL1 |= (1 << 23)
      | 1 << 14
      | 3 << 12
      | 1 << 10
      | 1 << 8
      | 1UL << 32
      | 28 << 0;
 asm volatile ("msr tcr_el1, %0" : : "r" (nTCR_EL1));
 u64 nSCTLR_EL1;
 asm volatile ("mrs %0, sctlr_el1" : "=r" (nSCTLR_EL1));
 nSCTLR_EL1 &= ~( (1 << 19)
   | (1 << 1));
 nSCTLR_EL1 |= (1 << 12)
        | (1 << 2)
        | (1 << 0);
 asm volatile ("msr sctlr_el1, %0" : : "r" (nSCTLR_EL1) : "memory");
}
```
