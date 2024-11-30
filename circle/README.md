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

* `cnthctl_el2`
* `cntp_ctl_el0`
* `cntp_cval_el0`
* `cntvoff_el2`
* `cpacr_el1`:    0x0000000000300000
* `cptr_el2`
* `daif`
* `daifclr`
* `daifset`
* `elr_el1`:      0x00000000000a9470
* `elr_el2`
* `hcr_el2`
* `hstr_el2`
* `mair_el1`:     0x00000000000004ff
* `sctlr_el1`:    0x0000000030d01805
* `sp_el1`
* `spsr_el1`:     0x0000000060000304
* `spsr_el2`
* `tcr_el1`:      0x000000010080751c
* `ttbr0_el1`:    0x0000000007000000
* `vbar_el1`:     0x00000000000af800
* `vbar_el2`
* `vmpidr_el2`
* `vpidr_el2`

Spectrum +4 currently updates the following ARM registers:

* `daifclr`
* `daifset`
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

This suggests spectrum4 updates to the following registers might be superfluous:

* `elr_el3`
* `scr_el3`
* `spsr_el3`
* `ttbr1_el1`

And updates to the following registers should be considered:

* `cnthctl_el2`
* `cntp_ctl_el0`
* `cntp_cval_el0`
* `cntvoff_el2`
* `cpacr_el1`
* `cptr_el2`
* `daif`
* `elr_el1`
* `hstr_el2`
* `sp_el1`
* `spsr_el1`
* `vbar_el2`
* `vmpidr_el2`
* `vpidr_el2`

It would also be beneficial to dump the values of all of these registers in
both projects to compare them. See
https://developer.arm.com/documentation/ddi0601/2024-09/AArch64-Registers?lang=en
for descriptions of the registers.
