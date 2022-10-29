# ZX Spectrum +4

A modern-day ZX Spectrum OS rewritten from scratch in ARM assembly (aarch64) to
run natively on RPi +3B.

If you are not familiar with the ZX Spectrum computer from the 1980's, there
are some excellent emulators around, such as [Retro Virtual
Machine](http://www.retrovirtualmachine.org/), and even some very good online
emulators that you can run directly in your browser.

This repo just contains notes about the development of the project. The actual
code lives at https://github.com/spectrum4/spectrum4.

# Table Of Contents

   * [1. Motivation](#1-motivation)
   * [2. Strategy](#2-strategy)
      * [2.1 RPi 3B kernel bootloading over home network - DONE](#21-rpi-3b-kernel-bootloading-over-home-network---done)
      * [2.2 Document compiled assembly of Zoltan Baldaszti's RPi 3B framebuffer tutorial](#22-document-compiled-assembly-of-zoltan-baldasztis-rpi-3b-framebuffer-tutorial)
      * [2.3 Render updated ZX Spectrum  2/ 3 main menu](#23-render-updated-zx-spectrum-23-main-menu)
      * [2.4 Get JTAG working](#24-get-jtag-working)
      * [2.5 Port ZX Spectrum 48K ROM](#25-port-zx-spectrum-48k-rom)
      * [2.6 Port remaining ZX Spectrum  2/ 3 ROMs](#26-port-remaining-zx-spectrum-23-roms)
   * [3. My Setup](#3-my-setup)
   * [4. Contributing](#4-contributing)
   * [5. RPi 3B Bootloading](#5-rpi-3b-bootloading)
      * [5.1 Option 1 - RPi 3B Bootloading From Another RPi Running TFTP Server](#51-option-1---rpi-3b-bootloading-from-another-rpi-running-tftp-server)
      * [5.2 Option 2 - RPi 3B Bootloading From A MacOS TFTP Server](#52-option-2---rpi-3b-bootloading-from-a-macos-tftp-server)
      * [5.3 Option 3 - RPi 3B Bootloading From A Docker Container Running A TFTP Server](#53-option-3---rpi-3b-bootloading-from-a-docker-container-running-a-tftp-server)
      * [5.4 Option 4 - RPi 3B Bootloading From A Windows TFTP Server](#54-option-4---rpi-3b-bootloading-from-a-windows-tftp-server)
   * [6. Links](#6-links)
      * [6.1 RPi Bare Metal RPi Development](#61-rpi-bare-metal-rpi-development)
      * [6.2 RPi Assembly under Linux](#62-rpi-assembly-under-linux)
      * [6.3 ARM Cortex A53 Reference](#63-arm-cortex-a53-reference)
      * [6.4 BCM283x Reference](#64-bcm283x-reference)
      * [6.5 VideoCore IV](#65-videocore-iv)
      * [6.6 RPi JTAG](#66-rpi-jtag)
      * [6.7 USB Keyboard](#67-usb-keyboard)
      * [6.8 ZX Spectrum](#68-zx-spectrum)

# 1. Motivation

Do you ever miss single-tasking computing, when you could write and run
programs on your computer, and the computer didn't do anything else at the same
time? You could simply and easily control all the peripherals of the computer,
such as the screen and the sound chip, and you didn't have to worry if this
might conflict with another program. The whole computer belonged to your
program, and your program only!  There were far fewer layers in the software
stack, and it was much easier to get started as a programmer.

The Spectrum +2A/+3 had 4 16K ROMs, which contained the Operating System. It
was written in Z80 assembly. This project aims to adapt the original Spectrum
+2A/+3 ROMs to ARM assembly, to run natively on the Raspberry Pi 3B. There
exist plenty of ZX Spectrum emulators, however they cannot take advantage of
the superior hardware that is available today. Therefore rather than writing
yet another emulator, I instead wanted to rewrite the ROM as if Sinclair or
Amstrad were releasing the latest and greatest Spectrum onto the market,
running on a Raspberry Pi. In other words, a Spectrum whose Operating System is
in keeping with the original Operating System, but that takes advantage of the
improved hardware that is available today, such as higher screen resolution,
improved sound capabilities, and more memory.

I would like the ZX Spectrum +4 to support saving to and loading from cassette
tape, like the original versions, mostly for nostalgia. I anticipate adding
support for saving to and loading from SD card / USB storage too, but I'm keen
to recreate the original tape loading/saving experience with the stripy screen
borders.

# 2. Strategy

This is the sequence of steps I intend to follow:

- [x] RPi 3B kernel bootloading over home network
- [x] Document compiled assembly of [Zoltan Baldaszti's RPi 3B framebuffer tutorial](https://github.com/bztsrc/raspi3-tutorial/tree/master/09_framebuffer)
- [x] Render updated ZX Spectrum +2/+3 main menu as a simple bitmap
- [x] Understand how interrupts are configured and work on the ZX Spectrum
- [x] Get a USB keyboard example working on bare metal
- [x] Get USB keyboard input working from assembly program
- [x] Decide on a toolchain to use (GNU binutils/FASMARM/...)
- [ ] Understand how interrupts are configured and work on the RPi
- [ ] Port some initial routines that don't generate or interpret sound
- [ ] Get sound output working via headphone socket
- [ ] Get sound output working via HDMI
- [ ] Get sound output working via USB
- [ ] Write assembly to generate sound
- [ ] Get sound input working via USB
- [ ] Write assembly that can sample/interpret audio from real spectrum tape
- [ ] Get JTAG working
- [ ] Port ZX Spectrum 48K ROM
- [ ] Port remaining ZX Spectrum +2/+3 ROMs
- [ ] Render graphics using GPU rather than writing directly to framebuffer with CPU
- [ ] Try to rewrite the code to use all four cores
- [ ] Rewrite the USB driver in assembly
- [ ] Write custom gpu firmware in VC4 assembly

## 2.1 RPi 3B kernel bootloading over home network - DONE

My first goal was to implement RPi kernel bootloading over my home network, so
that I could develop on my Mac, restart my RPi 3B, and have my changes
reloaded, without needing to physically remove and reinsert the SD card from my
RPi. That is now done, see [RPi 3B Bootloading](#5-rpi-3b-bootloading) below.

## 2.2 Document compiled assembly of Zoltan Baldaszti's RPi 3B framebuffer tutorial

Zoltan Baldaszti has kindly created a RPi 3B bare metal tutorial which
contains [an
exercise](https://github.com/bztsrc/raspi3-tutorial/tree/master/09_framebuffer)
that paints Homer Simpson to the display. It uses the aarch64 instruction set,
so should offer a good introduction to rendering pixels to a display using
aarch64 instruction set, which will be key for the screen drawing activities we
will be faced with later.

I have built his example kernel, disassembled it, and am going through the
disassembly line by line, to understand how it works. I have begun documenting
the disassembled code below. I have been referring to the following useful
documents to guide me:

* [ARM Cortex-A53 MPCore Processor Technical Reference
  Manual](https://developer.arm.com/docs/ddi0500/j)
* [The ARMv8 Instruction Set
  Overview](https://www.element14.com/community/servlet/JiveServlet/previewBody/41836-102-1-229511/ARM.Reference_Manual.pdf)
* [The A64 Instruction
  Set](https://static.docs.arm.com/100898/0100/the_a64_Instruction_set_100898_0100.pdf)
* [ARM Architecture Reference Manual ARMv8, for ARMv8-A architecture
  profile](https://developer.arm.com/docs/ddi0487/latest/arm-architecture-reference-manual-armv8-for-armv8-a-architecture-profile)

In addition, chapters 16 to 20 of [The armasm User
Guide](https://static.docs.arm.com/dui0801/i/DUI0801I_armasm_user_guide.pdf?_ga=2.140209011.1305908269.1541444114-1114139748.1539604101)
have provided a more detailed and complete reference of available aarch64
instructions. The armasm assembly syntax appears to be mostly compatible with
the disassembly generated by the [GNU
binutils](https://www.gnu.org/software/binutils) objdump utility, which is the
tool I used for generating the disassembled code below.

In particular, instructions are provided in alphabetical order:

* [General aarch64
   instructions](https://static.docs.arm.com/dui0801/i/DUI0801I_armasm_user_guide.pdf?_ga=2.140209011.1305908269.1541444114-1114139748.1539604101#_OPENTOPIC_TOC_PROCESSING_d180e201797)
* [Data transfer aarch64
  instructions](https://static.docs.arm.com/dui0801/i/DUI0801I_armasm_user_guide.pdf?_ga=2.140209011.1305908269.1541444114-1114139748.1539604101#_OPENTOPIC_TOC_PROCESSING_d180e238933)
* [Floating-point aarch64
  instructions](https://static.docs.arm.com/dui0801/i/DUI0801I_armasm_user_guide.pdf?_ga=2.140209011.1305908269.1541444114-1114139748.1539604101#_OPENTOPIC_TOC_PROCESSING_d180e271634)
* [SIMD scalar aarch64
  instructions](https://static.docs.arm.com/dui0801/i/DUI0801I_armasm_user_guide.pdf?_ga=2.140209011.1305908269.1541444114-1114139748.1539604101#_OPENTOPIC_TOC_PROCESSING_d180e288406)
* [SIMD vector aarch64
  instructions](https://static.docs.arm.com/dui0801/i/DUI0801I_armasm_user_guide.pdf?_ga=2.140209011.1305908269.1541444114-1114139748.1539604101#_OPENTOPIC_TOC_PROCESSING_d180e310895)

Alternatively, [The A64 Instruction Set
Reference](https://developer.arm.com/docs/100076/latest/part-d-a64-instruction-set-reference)
seems to provide similar information.

Here is the commented disassembly so far:

```assembly

kernel8.elf:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000080000 <_start>:

; This section will trigger cores 1,2,3 to sleep, and allow core 0 to continue running

   ; Read MPIDR_EL1 register into X1.
   ; This is the Multiprocessor Affinity Register which tells us which core is
   ; executing this instruction. All cores start executing code at 0x80000
   ; when the kernel is booted, but we are going to deactivate three of them
   ; so that only one of them renders Homer Simpson.
   ;
   ; See http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0500j/BABHBJCI.html
   80000:	d53800a1 	mrs	x1, mpidr_el1

   ; We can ignore 62 of the 64 bits, and just look at bits 0 and 1 to get a
   ; core number between 0 and 3. So logical AND with #3 and get the result back
   ; in x1 register.
   80004:	92400421 	and	x1, x1, #0x3

   ; Jump to 0x80014 if current core is core 0
   80008:	b4000061 	cbz	x1, 80014 <_start+0x14>

   ; The next two instructions put the remaining cores (1, 2, 3) in an infinite
   ; loop of waiting for an interrupt, and if they are woken up, to go back to
   ; sleep again.

   ; Wait for an interrupt event
   8000c:	d503205f 	wfe

   ; Return to 0x8000c
   80010:	17ffffff 	b	8000c <_start+0xc>

; This locates stack pointer at 0x80000, which is where code starts, so presumably
; the stack grows downwards, with the first entry's last byte located at 0x7ffff
; since executable code starts at 0x80000.

   ; Load x1 with contents of 0x80040, which is 0x0000000000080000 = 0x80000
   80014:	58000161 	ldr	x1, 80040 <_start+0x40>

   ; Set the stack pointer to 0x80000. This is the start address of this assembly,
   ; but that does not matter since the stack grows downwards, immediately before
   ; this memory location, so memory location 0x80000 is not used by the stack.
   80018:	9100003f 	mov	sp, x1

; Zero out 176 bytes of space (22 double words) for statically allocated
; variables, at 0x866f0, i.e. 0x866f0 - 0x8679f
;
; 0x866f0-0x866f7: (8 bytes):   framebuffer address
; 0x866f8-0x866fb: (4 bytes):   framebuffer pitch (bytes per line)
; 0x866fc-0x866ff: (4 bytes):   screen height
; 0x86700-0x86703: (4 bytes):   screen width
; 0x86704-0x8670f: (12 bytes):  < --- purpose unknown --- >
; 0x86710-0x8679b: (140 bytes): framebuffer mailbox request
; 0x8679c-0x8679f: (4 bytes):   < --- purpose unknown --- >

   ; Load x1 with contents of 0x08848, which is 0x00000000000866f0 = 0x866f0
   ; This address maps to the bss section where statically allocated variables
   ; will be stored.
   8001c:	58000161 	ldr	x1, 80048 <_start+0x48>

   ; Load w2 (32 bit register) with contents of 0x8003c, which is 0x00000016 = 0x16 (=22)
   80020:	180000e2 	ldr	w2, 8003c <_start+0x3c>

   ; Jump to 0x80034 if w2 == 0
   80024:	34000082 	cbz	w2, 80034 <_start+0x34>

   ; Store the 64 bit zero register in (address stored in x1 register)
   ; and then add 8 to x1
   80028:	f800843f 	str	xzr, [x1], #8

   ; w2--
   8002c:	51000442 	sub	w2, w2, #0x1

   ; Jump to 0x80024 if w2 != 0
   80030:	35ffffa2 	cbnz	w2, 80024 <_start+0x24>


; Call routine at 0x803d0 (i.e. 'main')

   80034:	940000e7 	bl	803d0 <main>

; Send core 0 to sleep too - all done!

   80038:	17fffff5 	b	8000c <_start+0xc>

; Data block here, used by above code
   8003c:	00000016 	.word	0x00000016
   80040:	00080000 	.word	0x00080000
   80044:	00000000 	.word	0x00000000
   80048:	000866f0 	.word	0x000866f0
   8004c:	00000000 	.word	0x00000000


; This function calls `nop` for the number of times specified in w0. Note,
; the compiler has performed a strange "optimisation" - instead of checking if
; w0 == 0 it essentially checks if w0 - 1 + 1 == 0.
0000000000080050 <wait_cycles>:

   ; Jump to 0x80068 if w0 == 0, i.e. return from function if w0 == 0
   80050:	340000c0 	cbz	w0, 80068 <wait_cycles+0x18>

   ; w0--
   80054:	51000400 	sub	w0, w0, #0x1

   ; Do nothing (padding)
   80058:	d503201f 	nop

   ; w0--
   8005c:	51000400 	sub	w0, w0, #0x1

   ; Compare w0 + 1 to zero
   80060:	3100041f 	cmn	w0, #0x1

   ; If zero flag is not set, jump to 80058
   80064:	54ffffa1 	b.ne	80058 <wait_cycles+0x8>  ; b.any

   ; Return from function
   80068:	d65f03c0 	ret

   ; Do nothing - although this is never executed, since no execution
   ; paths ever reach this address
   8006c:	d503201f 	nop

; This function waits the number of microseconds (10^-6 seconds)
; specified in w0 register. The disassembly is kind of elaborate
; in that division by 1,000 is implemented as multiplication by
; the integer part of (2^71 / 1,000) followed by division by 2^71.
;
; The following example parameters are used in the instruction
; comments, to illustrate how the calculations are performed.
;
; Example 1)
;   wait time   = 50,000 (50 milliseconds)
;   clock freq  = 250,000,000 (250 MHz),
;   start count = 21,600,000,000,000 (uptime 1 day)
;   end count   = 21,600,012,500,000 (1 day + 50 milliseconds)
0000000000080070 <wait_msec>:

   ; Store w0 (number of microseconds to wait) in w2, since we are going to use
   ; x0 to store the physical count of the system counter. Only support 32 bit
   ; unsigned values, so discard upper 32 bits. Register w0 *is* the lower 32
   ; bits of x0, similarly w2 is the lower 32 bits of x2.
   ;
   ; Example 1)
   ;   w0 = 50,000
   ;   w2 = 50,000
   ;   x2 = 50,000 (since this `mov` sets upper 32 bits of x0 to 0)
   80070:	2a0003e2 	mov	w2, w0

   ; Move register cntfrq_el0 into x1. This tells us the system counter frequency in Hz.
   ;
   ; See https://static.docs.arm.com/ddi0487/da/DDI0487D_a_armv8_arm.pdf?_ga=2.11893491.637195177.1541534329-2041545432.1541106125#E29.AArch64cntfrqel0
   ;
   ; Example 1)
   ;   x1 = 250,000,000
   80074:	d53be001 	mrs	x1, cntfrq_el0

   ; Move register cntpct_el0 into x0. This tells us the physical count of the system counter.
   ;
   ; See https://static.docs.arm.com/ddi0487/da/DDI0487D_a_armv8_arm.pdf?_ga=2.11893491.637195177.1541534329-2041545432.1541106125#G29.5472014
   ;
   ; Example 1)
   ;   x0 = 21,600,000,000,000
   80078:	d53be020 	mrs	x0, cntpct_el0

   ; In order to divide by 1,000 this code first multiplies by the integer part
   ; of 2^71/1,000 and then divides by 2^71 by shifting bits 71 places to the
   ; right. In order to multiply by int(2^71/1,000) (0x20c49ba5e353f7cf), we
   ; need to get 0x20c49ba5e353f7cf into a 64 bit register (register x3) 16
   ; bits at a time. Here we set bits 0-15.
   ;
   ; Note, aarch64 has the `udiv` unsigned divide instruction, but the compiler
   ; has chosen not to use it. Perhaps it offers no performance benefit? I've
   ; no idea, and haven't taken any benchmarks to find out. Perhaps the
   ; the compiler doesn't know about it, or its use has to be enabled with a
   ; compiler flag etc.
   ;
   ; x3 = 0x000000000000f7cf
   8007c:	d29ef9e3 	mov	x3, #0xf7cf                	; #63439

   ; Set bits 16-31 of x3 to 0xe353.
   ;
   ; x3 = 0x00000000e353f7cf
   80080:	f2bc6a63 	movk	x3, #0xe353, lsl #16

   ; x1 = x1 / 2^3
   ;    = clock freq / 2^3
   ;
   ; Example 1)
   ;   x1 = 31,250,000
   80084:	d343fc21 	lsr	x1, x1, #3

   ; Set bits 32-47 of x3 to 0x9ba5.
   ;
   ; x3 = 0x00009ba5e353f7cf
   80088:	f2d374a3 	movk	x3, #0x9ba5, lsl #32

   ; Set bits 48-63 of x3 to 0x20c4
   ;
   ; x3 = 0x20c49ba5e353f7cf
   ;    = 2361183241434822607
   ;    = int(2^71/1,000)
   8008c:	f2e41883 	movk	x3, #0x20c4, lsl #48

   ; x1 = bits 64-127 of (x1 * x3)
   ;    = x1 * x3 / 2^64
   ;    = clock freq * 2^4 / 1,000
   ;
   ; Example 1)
   ;   x1 = bits 64-127 of 0x3d09000000000000487ab0
   ;      = 0x3d0900
   ;      = 4,000,000
   80090:	9bc37c21 	umulh	x1, x1, x3

   ; x1 = x1 / 2^4
   ;    = clock freq / 1,000
   ;
   ; Example 1)
   ;   x1 = 250,000
   80094:	d344fc21 	lsr	x1, x1, #4

   ; x1 = x1 * x2
   ;    = x1 * w2
   ;    = clock freq * wait time / 1,000
   ;
   ; Example 1)
   ;   x1 = 250,000 * 50,000
   ;      = 12,500,000,000
   80098:	9b027c21 	mul	x1, x1, x2

   ; x1 = x1 / 2^3
   ;    = clock freq * wait time / (2^3 * 1,000)
   ;
   ; Example 1)
   ;   x1 = 1,562,500,000
   8009c:	d343fc21 	lsr	x1, x1, #3

   ; x1 = bits 64-127 of (x1 * x3)
   ;    = x1 * x3 / 2^64
   ;    = clock freq * wait time * 2^71 / (1,000 * 1,000 * 2^(64 + 3))
   ;    = clock freq * wait time * 2^4 / 1,000,000
   ;
   ; Example 1)
   ;   x1 = bits 64-127 of 0xbebc200000000000e27f660
   ;      = 0xbebc200
   ;      = 200,000,000
   800a0:	9bc37c21 	umulh	x1, x1, x3

   ; x0 = x0 + x1 / 2^4
   ;    = start count + (clock freq * wait time / 1,000,000)
   ;
   ; Example 1)
   ;   x0 = 21,600,000,000,000 + 12,500,000
   ;      = 21,600,012,500,000
   800a4:	8b411000 	add	x0, x0, x1, lsr #4

   ; Move register cntfrq_el0 into x1 (as before) to get the system counter
   ; frequency in Hz again.
   800a8:	d53be021 	mrs	x1, cntpct_el0

   ; Compare x0 and x1
   800ac:	eb01001f 	cmp	x0, x1

   ; If x0 > x1 jump back to 0x800a8
   800b0:	54ffffc8 	b.hi	800a8 <wait_msec+0x38>  ; b.pmore

   ; Return from function
   800b4:	d65f03c0 	ret

   ; 8 bytes padding since functions need to start on 16 byte boundaries.
   ; See page 14 of
   ;   https://community.arm.com/cfs-file/__key/telligent-evolution-components-attachments/01-2142-00-00-00-00-52-01/Porting-to-ARM-64_2D00_bit.pdf
   ; "Although not available as a general purpose register, the Stack Pointer must
   ; be 16-byte aligned at any public interface. It must also be 16-byte aligned at
   ; any point where it is used to access memory. This is enforced in hardware. Note
   ; that the alignment check is on the stack pointer and not on the address which
   ; is actually accessed."
   800b8:	d503201f 	nop
   800bc:	d503201f 	nop

; This function puts the system timer counter in x0. This counter increments
; every microsecond (1,000,000 increments per second, i.e. 1MHz). I'm not sure
; how much error margin there is, and whether the clock has a variable speed or
; a constant speed.
00000000000800c0 <get_system_timer>:

   ; Put 0x3f003008 in x2
   ;
   ; This is the MMIO address of the 'CHI: System Timer Counter Higher 32 bits'
   ; register of the System Timer Registers on page 172 of
   ; https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf
   ; Note, the peripheral base address in BCM2835 is located at 0x7e000000 but is
   ; located at 0x3f000000 in BCM2837, hence why this is 0x3f003008 and not
   ; 0x7e003008.
   800c0:	d2860102 	mov	x2, #0x3008                	; #12296
   800c4:	f2a7e002 	movk	x2, #0x3f00, lsl #16

   ; Put 0x3f003004 in x3
   ;
   ; This is the MMIO address of the 'CLO: System Timer Counter Lower 32 bits'
   ; register to complement CHI in x2 above.
   800c8:	d2860083 	mov	x3, #0x3004                	; #12292
   800cc:	f2a7e003 	movk	x3, #0x3f00, lsl #16

   ; Load w0 (32 bit register) with CHI System Timer register
   800d0:	b9400040 	ldr	w0, [x2]

   ; Load w1 (32 bit register) with CLO System Timer register
   800d4:	b9400061 	ldr	w1, [x3]

   ; Load w4 (32 bit register) with CHI System Timer register, to check if it
   ; changed in between reading CLO register
   800d8:	b9400044 	ldr	w4, [x2]

   ; Check the two reads of CHI gave consistent results, and if so, jump to
   ; 0x800ec
   800dc:	6b00009f 	cmp	w4, w0
   800e0:	54000060 	b.eq	800ec <get_system_timer+0x2c>  ; b.none

   ; The consecutive reads os CHI gave different results, so read CHI, CLO again.
   ; This time we can be confident that CHI didn't change, because that should only
   ; happen every 2^32 microseconds, i.e. about every 35 minutes, and we know it
   ; only just changed a couple of instructions ago.
   800e4:	b9400040 	ldr	w0, [x2]
   800e8:	b9400061 	ldr	w1, [x3]

   ; This sets the upper 32 bits of x1 to zero, which is needed for subsequent
   ; ORR statement. See
   ; http://infocenter.arm.com/help/topic/com.arm.doc.den0024a/DEN0024A_v8_architecture_PG.pdf#I7.5.1043011
   ;
   ; "Reads from W registers disregard the higher 32 bits of the corresponding
   ; X register and leave them unchanged. Writes to W registers set the higher 32
   ; bits of the X register to zero. That is, writing 0xFFFFFFFF into W0 sets X0 to
   ; 0x00000000FFFFFFFF."
   800ec:	2a0103e1 	mov	w1, w1

   ; This composes the CHI and CLO 32 bit values into the single 64 bit
   ; register x0.
   800f0:	aa008020 	orr	x0, x1, x0, lsl #32

   ; Return from function
   800f4:	d65f03c0 	ret

   ; Padding to reach 16 byte boundary for function.
   800f8:	d503201f 	nop
   800fc:	d503201f 	nop

; This function waits the number of microseconds (10^-6 seconds)
; specified in w0 register.
0000000000080100 <wait_msec_st>:

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ; The following block is inlined from function <get_system_timer> above
   ; (0x800c0 - 0x800f3) but puts the system clock counter in x1 instead of x0.
   ; See 0x800c0 - 0x800f3 for a commentary of these instructions.
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   80100:	d2860103 	mov	x3, #0x3008                	; #12296
   80104:	f2a7e003 	movk	x3, #0x3f00, lsl #16
   80108:	d2860084 	mov	x4, #0x3004                	; #12292
   8010c:	f2a7e004 	movk	x4, #0x3f00, lsl #16
   80110:	b9400065 	ldr	w5, [x3]
   80114:	b9400082 	ldr	w2, [x4]
   80118:	b9400061 	ldr	w1, [x3]
   8011c:	6b0100bf 	cmp	w5, w1
   80120:	54000060 	b.eq	8012c <wait_msec_st+0x2c>  ; b.none
   80124:	b9400061 	ldr	w1, [x3]
   80128:	b9400082 	ldr	w2, [x4]
   8012c:	2a0203e2 	mov	w2, w2
   80130:	aa018041 	orr	x1, x2, x1, lsl #32
   ;;;;;;; end of inlined (duplicated) code from 0x800c0 - 0x800f3 ;;;;;;;

   ; Jump to 0x8017c if x1 == 0, i.e. return from function if x1 == 0
   ; This is here in case this code is run in QEMU, where the system
   ; counter is not available. On a real functioning RPi 3B this
   ; should never be zero.
   80134:	b4000241 	cbz	x1, 8017c <wait_msec_st+0x7c>

   ; x0 = x1 + w0
   ;    = start microsecond clock counter + microseconds to wait
   ;    = target end counter
   ;
   ; For an explanation of 'uxtw' see
   ; https://static.docs.arm.com/100898/0100/the_a64_Instruction_set_100898_0100.pdf#%5B%7B%22num%22%3A35%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C54%2C629%2C0%5D
   80138:	8b204020 	add	x0, x1, w0, uxtw

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ; The following block is inlined again from function <get_system_timer> above
   ; (0x800c0 - 0x800f3) but puts the system clock counter in x1 instead of x0.
   ; See 0x800c0 - 0x800f3 for a commentary of these instructions.
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   8013c:	d2860103 	mov	x3, #0x3008                	; #12296
   80140:	f2a7e003 	movk	x3, #0x3f00, lsl #16
   80144:	d2860085 	mov	x5, #0x3004                	; #12292
   80148:	f2a7e005 	movk	x5, #0x3f00, lsl #16
   8014c:	d503201f 	nop
   80150:	b9400064 	ldr	w4, [x3]
   80154:	b94000a2 	ldr	w2, [x5]
   80158:	b9400061 	ldr	w1, [x3]
   8015c:	6b01009f 	cmp	w4, w1
   80160:	54000060 	b.eq	8016c <wait_msec_st+0x6c>  ; b.none
   80164:	b9400061 	ldr	w1, [x3]
   80168:	b94000a2 	ldr	w2, [x5]
   8016c:	2a0203e2 	mov	w2, w2
   80170:	aa018041 	orr	x1, x2, x1, lsl #32
   ;;;;;;; end of inlined (duplicated) code from 0x800c0 - 0x800f3 ;;;;;;;

   ; If x0 <= x1, repeat above block, but skip initialising x3 and x5 again
   ; since they are unchanged, so jump to 0x80150 instead of 0x8013c.
   80174:	eb00003f 	cmp	x1, x0
   80178:	54fffec3 	b.cc	80150 <wait_msec_st+0x50>  ; b.lo, b.ul, b.last

   ; Return from function, since the clock counter has reached the target
   ; value.
   8017c:	d65f03c0 	ret

; This function initialises the frame buffer
0000000000080180 <lfb_init>:
   ; Transfer x29 (Frame Pointer) and x30 (Procedure Link Register) to 32-17
   ; bytes before the stack pointer. Update stack pointer to new location. Note
   ; this is a downward-growing stack.
   80180:	a9be7bfd 	stp	x29, x30, [sp, #-32]!

   ; w1 = 140
   80184:	52801181 	mov	w1, #0x8c                  	; #140

   ; w2 = 0x48003
   80188:	52900062 	mov	w2, #0x8003                	; #32771
   8018c:	72a00082 	movk	w2, #0x4, lsl #16

   ; Put stack pointer (sp) in frame pointer (x29)
   80190:	910003fd 	mov	x29, sp

   ; Store x19 on the *top* of the stack (not the bottom)
   ; Leave stack pointer pointing below the stack.
   80194:	f9000bf3 	str	x19, [sp, #16]

   ; From https://quequero.org/2014/04/introduction-to-arm-architecture:
   ;   "The ADRP instruction permits the calculation of the address at a 4KB
   ;   aligned memory region. In conjunction with an ADD(immediate) instruction,
   ;   or a Load/Store instruction with a 12-bit immediate offset, this allows
   ;   for the calculation of, or access to, any address within ±4GB of the
   ;   current PC."
   ;
   ; At first I didn't quite understand the instruction, so I looked in the
   ; "ARM® Architecture Reference Manual ARMv8, for ARMv8-A architecture profile"
   ; to find out what the instruction actually does at a bit level.
   ;
   ; See https://yurichev.com/mirrors/ARMv8-A_Architecture_Reference_Manual_(Issue_A.a).pdf#E14.A64instructionsADRP
   ;
   ; From the disassembly we can see that the raw instruction is 0xd0000020. From
   ; this, following the manual, we can extract the parameters of the instruction:
   ;
   ;   machine code instruction
   ;         = 0xd-->0-->0-->0-->0-->0-->2-->0-->
   ;         = 0b11010000000000000000000000100000
   ;             |<><---><-----------------><--->
   ;             o i  1           i           R
   ;             p m  0           m           d
   ;               m  0           m
   ;               l  0           h
   ;               o  0           i
   ; =>
   ;   op    = 1
   ;   page  = 1
   ;   immlo = 0b10
   ;   immhi = 0b0000000000000000001
   ;   d     = 0b 0 0000
   ;   imm   = SignExtend(immhi:immlo:Zeros(12), 64);
   ;         = 0b 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0110 0000 0000 0000
   ;
   ; The manual then explains what this operation does at a bit level:
   ;
   ; bits(64) base = PC[];
   ; =>
   ;   base  = 0x80198 (the program counter is just the address of this instruction)
   ;         = 0b 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 1000 0000 0001 1001 1000
   ;
   ; if page then
   ;     base<11:0> = Zeros(12)
   ; =>
   ;   base  = 0b 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 1000 0000 0000 0000 0000
   ;
   ; X[d] = base + imm;
   ; =>
   ;   x0    = 0b 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 1000 0110 0000 0000 0000
   ;         = 0x86000
   ;
   ; So in the end this instruction is equivalent to `mov x0, 86000`, but the major difference is
   ; if you moved this code to a different memory location, the value of x0 would change. That
   ; isn't the case if you hardcode 86000 into the instruction, which is maybe why the compiler
   ; opted to use `adrp`, so the code is easier to relocate to a different memory location, if
   ; someone chose to do so. Note, not all the assembly is relocatable, e.g. there are hardcoded
   ; addresses in other memory locations, such as in 0x80048.
   ;
   ; The immediate (imm) is 24K (i.e. six 4K pages), so really this instruction is just saying
   ; "Put the page address of the 4K page in x0, which is six 4K pages higher than the page of
   ; the current instruction". Presumably the C compiler worked out that six 4K pages later is
   ; far enough away from the compiled code, that it is available for use.
   80198:	d0000020 	adrp	x0, 86000 <uart_hex+0x59a0>

   ; x19 = 0x86710
   ;
   ; Address range 0x86710-0x8679b is going to be where the data is to be stored for initialising
   ; the framebuffer. Store the base address is x19.
   8019c:	911c4013 	add	x19, x0, #0x710

; The *only thing* the following section does is initialise the following memory block, which
; is a property channel (mailbox channel 8) message to the GPU to initialise a framebuffer.
;
; See
;   * https://jsandler18.github.io/extra/prop-channel.html
;   * https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
;   * https://github.com/BrianSidebotham/arm-tutorial-rpi/tree/master/part-5#mailbox-property-interface
;
; x19:       0x86710: 140        Buffer size
; x19+4:     0x86714: 0          Request/response code
; x19+8:     0x86718: 0x48003    Tag 0 - Set Screen Size
; x19+12:    0x8671c: 8            value buffer size
; x19+16;    0x86720: 8            request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
; x19+20;    0x86724: 1024         request: width                response: width
; x19+24;    0x86728: 768          request: height               response: height
; x19+28;    0x8672c: 0x48004    Tag 1 - Set Virtual Screen Size
; x19+32;    0x86730: 8            value buffer size
; x19+36;    0x86734: 8            request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
; x19+40;    0x86738: 1024         request: width                response: width
; x19+44;    0x8673c: 768          request: height               response: height
; x19+48;    0x86740: 0x48009    Tag 2 - Set Virtual Offset
; x19+52;    0x86744: 8            value buffer size
; x19+56;    0x86748: 8            request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
; x19+60;    0x8674c: 0            request: x offset             response: x offset
; x19+64;    0x86750: 0            request: y offset             response: y offset
; x19+68;    0x86754: 0x48005    Tag 3 - Set Colour Depth
; x19+72;    0x86758: 4            value buffer size
; x19+76;    0x8675c: 4            request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
;                                  32 bits per pixel => 8 red, 8 green, 8 blue, 8 alpha
;                                  See https://en.wikipedia.org/wiki/RGBA_color_space
; x19+80;    0x86760: 32           request: bits per pixel       response: bits per pixel
; x19+84;    0x86764: 0x48006    Tag 4 - Set Pixel Order (really is "Colour Order", not "Pixel Order")
; x19+88;    0x86768: 4            value buffer size
; x19+92;    0x8676c: 4            request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
; x19+96;    0x86770: 1            request: 0 => BGR, 1 => RGB   response: 0 => BGR, 1 => RGB
; x19+100;   0x86774: 0x40001    Tag 5 - Get (Allocate) Buffer
; x19+104;   0x86778: 8            value buffer size (response > request, so use response size)
; x19+108;   0x8677c: 8            request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
; x19+112;   0x86780: 4096         request: alignment in bytes   response: frame buffer base address
; x19+116;   0x86784: 0            request: padding              response: frame buffer size in bytes
; x19+120;   0x86788: 0x40008    Tag 6 - Get Pitch (bytes per line)
; x19+124;   0x8678c: 4            value buffer size
; x19+128;   0x86790: 4            request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
; x19+132;   0x86794: 0            request: padding              response: bytes per line
; x19+136;   0x86798: 0          End Tags

   ; x19:       0x86710: 140
   ;
   ; Note, x0 + 1808 = x0 + 0x710 = 0x86710 = x19. Strangely the compiler used
   ; `str w1, [x0, #1808]` but could have also used `str w1, [x19]`.
   801a0:	b9071001 	str	w1, [x0, #1808]

   ; w1 = 8
   801a4:	52800101 	mov	w1, #0x8                   	; #8

   ; w3 = 1024
   801a8:	52808003 	mov	w3, #0x400                 	; #1024

   ; w0 = 768
   801ac:	52806000 	mov	w0, #0x300                 	; #768

   ; x19+4:     0x86714: 0
   801b0:	b900067f 	str	wzr, [x19, #4]

   ; w4 = 0x48004
   801b4:	52900084 	mov	w4, #0x8004                	; #32772
   801b8:	72a00084 	movk	w4, #0x4, lsl #16

   ; x19+8:     0x86718: 0x48003
   801bc:	b9000a62 	str	w2, [x19, #8]

   ; w10 = 0x48009
   801c0:	5290012a 	mov	w10, #0x8009                	; #32777
   801c4:	72a0008a 	movk	w10, #0x4, lsl #16

   ; x19+12:    0x8671c: 8
   801c8:	b9000e61 	str	w1, [x19, #12]

   ; w9 = 0x48005
   801cc:	529000a9 	mov	w9, #0x8005                	; #32773
   801d0:	72a00089 	movk	w9, #0x4, lsl #16

   ; x19+16;    0x86720: 8
   801d4:	b9001261 	str	w1, [x19, #16]

   ; w2 = 4
   801d8:	52800082 	mov	w2, #0x4                   	; #4

   ; x19+20;    0x86724: 1024
   801dc:	b9001663 	str	w3, [x19, #20]

   ; w8 = 32
   801e0:	52800408 	mov	w8, #0x20                  	; #32

   ; x19+24;    0x86728: 768
   801e4:	b9001a60 	str	w0, [x19, #24]

   ; w7 = 0x48006
   801e8:	529000c7 	mov	w7, #0x8006                	; #32774
   801ec:	72a00087 	movk	w7, #0x4, lsl #16

   ; x19+28;    0x8672c: 0x48004
   801f0:	b9001e64 	str	w4, [x19, #28]

   ; w6 = 1
   801f4:	52800026 	mov	w6, #0x1                   	; #1

   ; x19+32;    0x86730: 8
   801f8:	b9002261 	str	w1, [x19, #32]

   ; w5 = 0x40001
   801fc:	52800025 	mov	w5, #0x1                   	; #1
   80200:	72a00085 	movk	w5, #0x4, lsl #16

   ; x19+36;    0x86734: 8
   80204:	b9002661 	str	w1, [x19, #36]

   ; w4 = 4096
   80208:	52820004 	mov	w4, #0x1000                	; #4096

   ; x19+40;    0x86738: 1024
   8020c:	b9002a63 	str	w3, [x19, #40]

   ; w3 = 0x40008
   80210:	52800103 	mov	w3, #0x8                   	; #8
   80214:	72a00083 	movk	w3, #0x4, lsl #16

   ; x19+44;    0x8673c: 768
   80218:	b9002e60 	str	w0, [x19, #44]

   ; w0 = w1 = 8 - this is MBOX_CH_PROP
   8021c:	2a0103e0 	mov	w0, w1

   ; x19+48;    0x86740: 0x48009
   80220:	b900326a 	str	w10, [x19, #48]

   ; x19+52;    0x86744: 8
   80224:	b9003661 	str	w1, [x19, #52]

   ; x19+56;    0x86748: 8
   80228:	b9003a61 	str	w1, [x19, #56]

   ; x19+60;    0x8674c: 0
   8022c:	b9003e7f 	str	wzr, [x19, #60]

   ; x19+64;    0x86750: 0
   80230:	b900427f 	str	wzr, [x19, #64]

   ; x19+68;    0x86754: 0x48005
   80234:	b9004669 	str	w9, [x19, #68]

   ; x19+72;    0x86758: 4
   80238:	b9004a62 	str	w2, [x19, #72]

   ; x19+76;    0x8675c: 4
   8023c:	b9004e62 	str	w2, [x19, #76]

   ; x19+80;    0x86760: 32
   80240:	b9005268 	str	w8, [x19, #80]

   ; x19+84;    0x86764: 0x48006
   80244:	b9005667 	str	w7, [x19, #84]

   ; x19+88;    0x86768: 4
   80248:	b9005a62 	str	w2, [x19, #88]

   ; x19+92;    0x8676c: 4
   8024c:	b9005e62 	str	w2, [x19, #92]

   ; x19+96;    0x86770: 1
   80250:	b9006266 	str	w6, [x19, #96]

   ; x19+100;   0x86774: 0x40001
   80254:	b9006665 	str	w5, [x19, #100]

   ; x19+104;   0x86778: 8
   80258:	b9006a61 	str	w1, [x19, #104]

   ; x19+108;   0x8677c: 8
   8025c:	b9006e61 	str	w1, [x19, #108]

   ; x19+112;   0x86780: 4096
   80260:	b9007264 	str	w4, [x19, #112]

   ; x19+116;   0x86784: 0
   80264:	b900767f 	str	wzr, [x19, #116]

   ; x19+120;   0x86788: 0x40008
   80268:	b9007a63 	str	w3, [x19, #120]

   ; x19+124;   0x8678c: 4
   8026c:	b9007e62 	str	w2, [x19, #124]

   ; x19+128;   0x86790: 4
   80270:	b9008262 	str	w2, [x19, #128]

   ; x19+132;   0x86794: 0
   80274:	b900867f 	str	wzr, [x19, #132]

   ; x19+136;   0x86798: 0
   80278:	b9008a7f 	str	wzr, [x19, #136]

; ------------------------------------------------------------------
; --------- Memory block (0x86710-0x8679b) now initialised ---------
; ------------------------------------------------------------------

   ; call mbox_call
   ; Note w0 = x0 = 8
   8027c:	94000061 	bl	80400 <mbox_call>

; Test call to mbox_call was successful (non-zero value in w0)

   ; if mbox_call was unsuccessful (w0 == 0), skip to failure message block below
   80280:	34000080 	cbz	w0, 80290 <lfb_init+0x110>

; Test 32 bit colour depth accepted

   ; Read from address (x19 + 80) into w0. From above, this is the mailbox
   ; response for 'bits per pixel':
   ; x19+80;    0x86760: 32           request: bits per pixel       response: bits per pixel
   80284:	b9405260 	ldr	w0, [x19, #80]

   ; Compare if it is 32 (i.e. that we successfully set colour depth to 32)
   80288:	7100801f 	cmp	w0, #0x20

   ; If address colour depth successfully set, skip to next test
   ; below to test framebuffer base address has been set
   8028c:	540000e0 	b.eq	802a8 <lfb_init+0x128>  ; b.none

; Write "Unable to set screen resolution to 1024x768x32" to UART0 (serial
; connection)

   ; Reinstate original x19 from the stack (that was stored in instruction at
   ; 0x80194). We must do this since x19-x28 are callee saved registers.
   80290:	f9400bf3 	ldr	x19, [sp, #16]

   ; x0 = 806b8 = address of message "Unable to set screen resolution ...."
   80294:	90000000 	adrp	x0, 80000 <_start>
   80298:	911ae000 	add	x0, x0, #0x6b8

   ; Reinstate x29 (frame pointer) and x30 (procedure link register) from the
   ; stack (they were stored in instruction at 0x80180).
   8029c:	a8c27bfd 	ldp	x29, x30, [sp], #32

   ; Jump directly (no stack update) to <uart_puts> method
   ; this works since there is nothing left to do in this function, so when
   ; uart_puts returns, it is ok to return to the function that called this one
   802a0:	140000d4 	b	805f0 <uart_puts>
   802a4:	d503201f 	nop

; Test framebuffer base address returned in mailbox

   ; read returned base address of framebuffer from mailbox into w0
   802a8:	b9407260 	ldr	w0, [x19, #112]

   ; if it isn't set (=0) go to section above to write failure message to UART0
   802ac:	34ffff20 	cbz	w0, 80290 <lfb_init+0x110>

; If we get this far, then mailbox call was successful
   ; This line seems pretty redundent, as we had it two instructions before
   802b0:	b9407260 	ldr	w0, [x19, #112]

   ; Set x2, x4 and x6 to address 86000, which will be used as a base address
   ; for calculating address inside bss section later.
   802b4:	d0000026 	adrp	x6, 86000 <uart_hex+0x59a0>
   802b8:	d0000024 	adrp	x4, 86000 <uart_hex+0x59a0>
   802bc:	d0000022 	adrp	x2, 86000 <uart_hex+0x59a0>

   ; Unset bits 30, 31 of the framebuffer base address. These should in any
   ; case be unset since the RPi 3B only has 1GB RAM. Probably this is just
   ; a safety check to make sure the address is in range.
   802c0:	12007400 	and	w0, w0, #0x3fffffff

   ; This writes back the address to memory, where it was read from.
   802c4:	b9007260 	str	w0, [x19, #112]

   ; Set x1 also to address 86000 for same reason as x2, x4, x6 above.
   802c8:	d0000021 	adrp	x1, 86000 <uart_hex+0x59a0>

   ; w7 = screen width
   802cc:	b9401667 	ldr	w7, [x19, #20]

   ; w5 = screen height
   802d0:	b9401a65 	ldr	w5, [x19, #24]

   ; w3 = pitch (bytes per line)
   802d4:	b9408663 	ldr	w3, [x19, #132]

   ; This seems like a wasted instruction, we just stored w0 here, and now are
   ; reading it back again, even though it didn't change in between.
   802d8:	b9407260 	ldr	w0, [x19, #112]

   ; Store screen width at 0x86700.
   802dc:	b90700c7 	str	w7, [x6, #1792]

   ; Reinstate original x19 from the stack (that was stored in instruction at
   ; 0x80194). We must do this since x19-x28 are callee saved registers.
   802e0:	f9400bf3 	ldr	x19, [sp, #16]

   ; Ensure upper 32 bits of x0 are zero, but I'm pretty sure they are
   ; guaranteed to be already, due to the earlier w0 instructions, such as
   ; the mov instruction at 0x801ac.
   802e4:	2a0003e0 	mov	w0, w0

   ; Store screen height at 0x866fc
   802e8:	b906fc85 	str	w5, [x4, #1788]

   ; Store pitch at 0x866f8
   802ec:	b906f843 	str	w3, [x2, #1784]

   ; Store 64 bit address of framebuffer in 0x866f0
   802f0:	f9037820 	str	x0, [x1, #1776]

   ; Reinstate x29 (frame pointer) and x30 (procedure link register) from the
   ; stack (they were stored in instruction at 0x80180).
   802f4:	a8c27bfd 	ldp	x29, x30, [sp], #32

   ; Return from function
   802f8:	d65f03c0 	ret
   802fc:	d503201f 	nop

0000000000080300 <lfb_showpicture>:

   ; x1 = 0x86000
   80300:	d0000021 	adrp	x1, 86000 <uart_hex+0x59a0>

   ; w6 = screen width (stored in 0x86700)
   80304:	b9470026 	ldr	w6, [x1, #1792]

   ; x0 = 0x86000
   80308:	d0000020 	adrp	x0, 86000 <uart_hex+0x59a0>

   ; w0 = screen height
   8030c:	b946fc00 	ldr	w0, [x0, #1788]

   ; x10 = 0x86000
   80310:	d000002a 	adrp	x10, 86000 <uart_hex+0x59a0>

   ; w2 = pitch (bytes per line)
   80314:	b946f942 	ldr	w2, [x10, #1784]

   ; w6 = screen width - homer width (96)
   80318:	510180c6 	sub	w6, w6, #0x60

   ; w0 = screen height - homer height (64)
   8031c:	51010000 	sub	w0, w0, #0x40

   ; w1 = 2 * (screen width - homer width)
   ;    = 4 * offset pixels from left of screen
   ;    = x byte offset (4 bytes per pixel)
   80320:	0b0600c1 	add	w1, w6, w6

   ; w0 = (screen height - homer height)/2 = number of screen rows above image
   80324:	53017c00 	lsr	w0, w0, #1

   ; x3 = 0x86000
   80328:	d0000023 	adrp	x3, 86000 <uart_hex+0x59a0>

   ; x6 = frame buffer address in 0x866f0
   8032c:	f9437866 	ldr	x6, [x3, #1776]

   ; x9 = 0x806e8 = base address of GIMP header image file format (RGB) of homer image
   80330:	90000009 	adrp	x9, 80000 <_start>
   80334:	911ba129 	add	x9, x9, #0x6e8

   ; w0 = w0 * w2 + w1
   ;    = pitch * number of screen rows above image + x byte offset
   ;    = total frambuffer offset for start of image inside framebuffer
   80338:	1b020400 	madd	w0, w0, w2, w1

   ; x11 = 86000
   8033c:	d000002b 	adrp	x11, 86000 <uart_hex+0x59a0>

   ; x10 = 866f8 = address of framebuffer pitch
   80340:	911be14a 	add	x10, x10, #0x6f8

   ; x11 = 0x866e8 = address immediately after end of encoded image
   80344:	911ba16b 	add	x11, x11, #0x6e8

   ; x6 = framebuffer base address + offset address
   ;    = address of first homer pixel
   80348:	8b0000c6 	add	x6, x6, x0
   8034c:	d503201f 	nop

   ;;;; outer loop (y axis) starts here

   ; x8 is the indirect result register
   ; See http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.den0024a/ch09s01s01.html
   ;
   ; x8 = address immediately after last pixel in row
   80350:	910600c8 	add	x8, x6, #0x180

   ; x2 = base address of encoded image
   80354:	aa0903e2 	mov	x2, x9

   ;;;; inner loop (x axis) starts here

   ; w1 = byte at (x2+1) ... that is data[1] from
   ; https://github.com/bztsrc/raspi3-tutorial/blob/7ace64ba9ff98011d37c74bba20890ccbd663ccb/09_framebuffer/homer.h#L9
   ; Note, 'ldrb immediate unsigned offset' accepts an immediate from 0 to 4095
   ; bytes.
   80358:	39400441 	ldrb	w1, [x2, #1]

   ; x2 += 4
   ; Strangely the compiler has prematurely bumped x2 here, so subsequent byte loads relating
   ; to the current iteration have negative offsets. If it had bumped x2 after reading the
   ; image bytes, they would have all had positive offsets.
   8035c:	91001042 	add	x2, x2, #0x4

   ; w3 = byte at (x2-4)  ... data[0]
   ; Note, ldurb only has 'unsigned immediate offset' variant, and accepts an
   ; immediate from -256 to 255 bytes.
   80360:	385fc043 	ldurb	w3, [x2, #-4]

   ; w0 = byte at (x2-2)  ... data[2]
   80364:	385fe040 	ldurb	w0, [x2, #-2]

   ; w1 = w1 - 33
   ;    = data[1] - 33
   80368:	51008421 	sub	w1, w1, #0x21

   ; w7 = w1 >> 4
   ;    = (data[1] - 33) >> 4
   8036c:	13047c27 	asr	w7, w1, #4

   ; w3 = w3 - 33
   ;    = data[0] - 33
   80370:	51008463 	sub	w3, w3, #0x21

   ; w0 = w0 - 33
   ;    = data[2] - 33
   80374:	51008400 	sub	w0, w0, #0x21

   ; w3 = w7 || (w3 << 2)
   ;    = ((data[1] - 33) >> 4) || ((data[0] - 33) << 2)
   ;    = pixel[0]
   80378:	2a0308e3 	orr	w3, w7, w3, lsl #2

   ; w5 = byte at (x2-1)  ... data[3]
   8037c:	385ff045 	ldurb	w5, [x2, #-1]

   ; w7 = w0 >> 2
   ;    = (data[2] - 33) >> 2
   80380:	13027c07 	asr	w7, w0, #2

   ; w1 = w7 || (w1 << 4)
   ;    = ((data[2] - 33) >> 2) || ((data[1] - 33) << 4)
   ;    = pixel[1] + possible set bit 9 / possible set bit 10
   80384:	2a0110e1 	orr	w1, w7, w1, lsl #4

   ; copy bits 0-7 of w3 into bits 0-7 of w4
   ; w4 = pixel[0] + random bits 8-31
   80388:	33001c64 	bfxil	w4, w3, #0, #8

   ; w5 = w5 - 31
   ;    = data[3] - 31
   8038c:	510084a5 	sub	w5, w5, #0x21

   ; w0 = w5 || (w0 << 6)
   ;    = (data[3] - 33) || ((data[2] - 33) << 6)
   ;    = pixel[2] + random bits 8-13
   80390:	2a0018a0 	orr	w0, w5, w0, lsl #6

   ; copy bits 0-7 of w1 into bits 8-15 of w4
   ; w4 = pixel[0] in bits 0-7
   ;      pixel[1] in bits 8-15
   ;      random bits 16-31
   80394:	33181c24 	bfi	w4, w1, #8, #8

   ; copy bits 0-7 of w0 into bits 16-23 of w4
   ; w4 = pixel[0] in bits 0-7
   ;      pixel[1] in bits 8-15
   ;      pixel[2] in bits 16-23
   ;      random bits 24-31
   80398:	33101c04 	bfi	w4, w0, #16, #8

   ; store w4 (pixel data) in x6 (pixel address in framebuffer) and increase x6 by 4
   8039c:	b80044c4 	str	w4, [x6], #4

   ; Compare pixel address with x8. x8 was calculated as x6 + 0x180 (384) earlier, so
   ; this happens after 96 loop interations (x6 increased by 4 each iteration) - which
   ; is the width in pixels of the image.
   803a0:	eb0800df 	cmp	x6, x8

   ; if x6 != x8, repeat from 0x80358
   ; this will keep repeating until pixel row is completed
   803a4:	54fffda1 	b.ne	80358 <lfb_showpicture+0x58>  ; b.any

   ; pixel row completed

   ; load framebuffer pitch in w0
   803a8:	b9400140 	ldr	w0, [x10]

   ; x9 now is address of first pixel in next row of encoded image
   803ac:	91060129 	add	x9, x9, #0x180

   ; check whether we've reached end of encoded image
   803b0:	eb0b013f 	cmp	x9, x11

   ; subtract image width in bytes from framebuffer width in bytes
   803b4:	51060000 	sub	w0, w0, #0x180

   ; add this difference to x6, which tracks the location in the framebuffer we
   ; are updating, so that we wrap from the end of one row, to the start of the
   ; next row
   803b8:	8b0000c6 	add	x6, x6, x0

   ; if we haven't reached the end of the image, repeat the procedure for the
   ; next row.
   803bc:	54fffca1 	b.ne	80350 <lfb_showpicture+0x50>  ; b.any

   ; Return from function
   803c0:	d65f03c0 	ret
	...

00000000000803d0 <main>:

   ; Push frame pointer (x29) and procedure link register (x30) onto the
   ; (downward-growing) stack, and update the stack pointer.
   ;
   ; See http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.den0024a/CJAIFJII.html
   803d0:	a9bf7bfd 	stp	x29, x30, [sp, #-16]!

   ; Move stack pointer address into frame pointer
   803d4:	910003fd 	mov	x29, sp

   ; Call uart_init function
   803d8:	94000026 	bl	80470 <uart_init>

   ; Call lfb_init function
   803dc:	97ffff69 	bl	80180 <lfb_init>

   ; Call lfb_showpicture function
   803e0:	97ffffc8 	bl	80300 <lfb_showpicture>

   ; padding, so next function sits on 64 bit boundary
   803e4:	d503201f 	nop

   ; Call uart_getc function
   803e8:	94000072 	bl	805b0 <uart_getc>

   ; Unset 24 most significant bits in w0, leaving 8 least significant bits.
   ; Presumably uart_getc set w0 to something interesting for us.
   803ec:	12001c00 	and	w0, w0, #0xff

   ; Call uart_send function
   803f0:	94000064 	bl	80580 <uart_send>

   ; Infinite loop - return to 0x803e8 above (uart_getc)
   803f4:	17fffffd 	b	803e8 <main+0x18>
	...

; See https://jsandler18.github.io/extra/mailbox.html for an overview of
; the mailbox peripheral interface.
0000000000080400 <mbox_call>:

   ; Retain only bits 0-3 of the channel stored in w0.
   ; The channel should probably only be 4 bits anyway.
   80400:	12000c00 	and	w0, w0, #0xf

   ; x4=0x86000
   80404:	d0000024 	adrp	x4, 86000 <uart_hex+0x59a0>

   ; x2=0x86710
   ; Set x2 to address where framebuffer initialisation block is stored.
   80408:	911c4082 	add	x2, x4, #0x710

   ; Logical OR w0 (channel) and w2 (framebuffer base address) and put results in w2
   ; Presumably, the base address has to be 16 byte aligned (which it is in this
   ; case) so that the address and the channel can be stored in 32 bits.
   8040c:	2a020002 	orr	w2, w0, w2

   ; x1 = 0x3f00b898
   ; Set x1 to Mailbox peripheral base address + 24 (0x18) which is the mailbox
   ; status register.
   80410:	d2971301 	mov	x1, #0xb898                	; #47256
   80414:	f2a7e001 	movk	x1, #0x3f00, lsl #16

   ; Padding
   80418:	d503201f 	nop

   ; Read mailbox status register into w0
   8041c:	b9400020 	ldr	w0, [x1]

   ; If bit 31 of mailbox status register (write register) isn't zero, repeat
   ; last step.
   ; See https://jsandler18.github.io/extra/mailbox.html#writing-to-the-mailbox
   80420:	37ffffc0 	tbnz	w0, #31, 80418 <mbox_call+0x18>

   ; x0 = 0x3f00b8a0
   ; Set x0 to Mailbox peripheral base address + 32 (0x20) which is the mailbox
   ; write register.
   80424:	d2971400 	mov	x0, #0xb8a0                	; #47264
   80428:	f2a7e000 	movk	x0, #0x3f00, lsl #16

   ; x1 = 0x3f00b898
   ; Set x1 to Mailbox peripheral base address + 24 (0x18) which is the mailbox
   ; status register.
   8042c:	d2971301 	mov	x1, #0xb898                	; #47256
   80430:	f2a7e001 	movk	x1, #0x3f00, lsl #16

   ; x3 = 0x3f00b880
   ; Set x3 to Mailbox peripheral base address (read register)
   80434:	d2971003 	mov	x3, #0xb880                	; #47232
   80438:	f2a7e003 	movk	x3, #0x3f00, lsl #16

   8043c:	b9000002 	str	w2, [x0]
   80440:	d503201f 	nop
   80444:	b9400020 	ldr	w0, [x1]
   80448:	37f7ffc0 	tbnz	w0, #30, 80440 <mbox_call+0x40>
   8044c:	b9400060 	ldr	w0, [x3]
   80450:	6b02001f 	cmp	w0, w2
   80454:	54ffff61 	b.ne	80440 <mbox_call+0x40>  ; b.any
   80458:	911c4084 	add	x4, x4, #0x710
   8045c:	52b00000 	mov	w0, #0x80000000            	; #-2147483648
   80460:	b9400481 	ldr	w1, [x4, #4]
   80464:	6b00003f 	cmp	w1, w0
   80468:	1a9f17e0 	cset	w0, eq  ; eq = none
   8046c:	d65f03c0 	ret

0000000000080470 <uart_init>:

   ; Push frame pointer (x29) and procedure link register (x30) onto the
   ; (downward-growing) stack, after leaving a gap of 32 bytes on the stack,
   ; and update the stack pointer.
   ;
   ; See http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.den0024a/CJAIFJII.html
   80470:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!

   ; x0=0x86000
   80474:	d0000020 	adrp	x0, 86000 <uart_hex+0x59a0>

   ; x1 = 0x86710 (address of framebuffer mailbox request)
   80478:	911c4001 	add	x1, x0, #0x710

   ; Move stack pointer address into frame pointer
   8047c:	910003fd 	mov	x29, sp

   ; Store x19, x20 on the stack immediately before frame pointer and link register
   80480:	a90153f3 	stp	x19, x20, [sp, #16]

   ; x19 = 0x3f201030 (address of UART0_CR)
   80484:	d2820613 	mov	x19, #0x1030                	; #4144
   80488:	f2a7e413 	movk	x19, #0x3f20, lsl #16

   ; store x21 on the stack before x20
   8048c:	f90013f5 	str	x21, [sp, #32]

   ; w2 = 32 (0x20)
   80490:	52800402 	mov	w2, #0x20                  	; #32

   ; [UART0_CR] = 0 (32 bits)
   80494:	b900027f 	str	wzr, [x19]

   ; w20 = 2
   80498:	52800054 	mov	w20, #0x2                   	; #2

   ; [0x86710] (mbox request + 0-3) = 32 (0x00000020)
   8049c:	b9071002 	str	w2, [x0, #1808]

   ; w0 = 0x00038002
   804a0:	52900040 	mov	w0, #0x8002                	; #32770
   804a4:	72a00060 	movk	w0, #0x3, lsl #16

   ; [0x86714] (mbox request + 4-7) = 0 (0x00000000)
   804a8:	b900043f 	str	wzr, [x1, #4]

   ; w2 = 12 (0x0000000c)
   804ac:	52800182 	mov	w2, #0xc                   	; #12

   ; [0x86718] (mbox request + 8-11) = 229378 (0x00038002)
   804b0:	b9000820 	str	w0, [x1, #8]

   ; w0 = 8
   804b4:	52800100 	mov	w0, #0x8                   	; #8

   ; [0x8671c] (mbox request + 12-15) = 12 (0x0000000c)
   804b8:	b9000c22 	str	w2, [x1, #12]

   ; w2 = 4000000 (0x003d0900)
   804bc:	52812002 	mov	w2, #0x900                 	; #2304
   804c0:	72a007a2 	movk	w2, #0x3d, lsl #16

   ; [0x86720] (mbox request + 16-19) = 8 (0x00000008)
   804c4:	b9001020 	str	w0, [x1, #16]

   ; x21 = 0x3f200098
   804c8:	d2801315 	mov	x21, #0x98                  	; #152
   804cc:	f2a7e415 	movk	x21, #0x3f20, lsl #16

   ; [0x86724] (mbox request + 20-23) = 2 (0x00000002)
   804d0:	b9001434 	str	w20, [x1, #20]

   ; [0x86728] (mbox request + 24-27) = 4000000 (0x003d0900)
   804d4:	b9001822 	str	w2, [x1, #24]

   ; [0x8672c] (mbox request + 28-31) = 0 (0x00000000)
   804d8:	b9001c3f 	str	wzr, [x1, #28]

   ; Call mbox_call function
   804dc:	97ffffc9 	bl	80400 <mbox_call>
   804e0:	d2800082 	mov	x2, #0x4                   	; #4
   804e4:	f2a7e402 	movk	x2, #0x3f20, lsl #16
   804e8:	d2801283 	mov	x3, #0x94                  	; #148
   804ec:	f2a7e403 	movk	x3, #0x3f20, lsl #16
   804f0:	b9400041 	ldr	w1, [x2]
   804f4:	52880004 	mov	w4, #0x4000                	; #16384
   804f8:	72a00044 	movk	w4, #0x2, lsl #16
   804fc:	120e6421 	and	w1, w1, #0xfffc0fff
   80500:	528012c0 	mov	w0, #0x96                  	; #150
   80504:	2a040021 	orr	w1, w1, w4
   80508:	b9000041 	str	w1, [x2]
   8050c:	b900007f 	str	wzr, [x3]
   80510:	97fffed0 	bl	80050 <wait_cycles>
   80514:	52980000 	mov	w0, #0xc000                	; #49152
   80518:	b90002a0 	str	w0, [x21]
   8051c:	528012c0 	mov	w0, #0x96                  	; #150
   80520:	97fffecc 	bl	80050 <wait_cycles>
   80524:	b90002bf 	str	wzr, [x21]
   80528:	d2820880 	mov	x0, #0x1044                	; #4164
   8052c:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   80530:	d2820482 	mov	x2, #0x1024                	; #4132
   80534:	f2a7e402 	movk	x2, #0x3f20, lsl #16
   80538:	f94013f5 	ldr	x21, [sp, #32]
   8053c:	5280ffe3 	mov	w3, #0x7ff                 	; #2047
   80540:	d2820501 	mov	x1, #0x1028                	; #4136
   80544:	f2a7e401 	movk	x1, #0x3f20, lsl #16
   80548:	b9000003 	str	w3, [x0]
   8054c:	d2820580 	mov	x0, #0x102c                	; #4140
   80550:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   80554:	b9000054 	str	w20, [x2]
   80558:	52800162 	mov	w2, #0xb                   	; #11
   8055c:	b9000022 	str	w2, [x1]
   80560:	52800c01 	mov	w1, #0x60                  	; #96
   80564:	b9000001 	str	w1, [x0]
   80568:	52806020 	mov	w0, #0x301                 	; #769
   8056c:	b9000260 	str	w0, [x19]
   80570:	a94153f3 	ldp	x19, x20, [sp, #16]
   80574:	a8c37bfd 	ldp	x29, x30, [sp], #48
   80578:	d65f03c0 	ret
   8057c:	d503201f 	nop

0000000000080580 <uart_send>:
   80580:	d2820302 	mov	x2, #0x1018                	; #4120
   80584:	f2a7e402 	movk	x2, #0x3f20, lsl #16
   80588:	d503201f 	nop
   8058c:	b9400041 	ldr	w1, [x2]
   80590:	372fffc1 	tbnz	w1, #5, 80588 <uart_send+0x8>
   80594:	d2820001 	mov	x1, #0x1000                	; #4096
   80598:	f2a7e401 	movk	x1, #0x3f20, lsl #16
   8059c:	b9000020 	str	w0, [x1]
   805a0:	d65f03c0 	ret
   805a4:	d503201f 	nop
   805a8:	d503201f 	nop
   805ac:	d503201f 	nop

00000000000805b0 <uart_getc>:
   805b0:	d2820301 	mov	x1, #0x1018                	; #4120
   805b4:	f2a7e401 	movk	x1, #0x3f20, lsl #16
   805b8:	d503201f 	nop
   805bc:	b9400020 	ldr	w0, [x1]
   805c0:	3727ffc0 	tbnz	w0, #4, 805b8 <uart_getc+0x8>
   805c4:	d2820000 	mov	x0, #0x1000                	; #4096
   805c8:	f2a7e400 	movk	x0, #0x3f20, lsl #16
   805cc:	52800141 	mov	w1, #0xa                   	; #10
   805d0:	b9400000 	ldr	w0, [x0]
   805d4:	12001c00 	and	w0, w0, #0xff
   805d8:	7100341f 	cmp	w0, #0xd
   805dc:	1a811000 	csel	w0, w0, w1, ne  ; ne = any
   805e0:	d65f03c0 	ret
   805e4:	d503201f 	nop
   805e8:	d503201f 	nop
   805ec:	d503201f 	nop

00000000000805f0 <uart_puts>:
   805f0:	39400001 	ldrb	w1, [x0]
   805f4:	34000221 	cbz	w1, 80638 <uart_puts+0x48>
   805f8:	d2820302 	mov	x2, #0x1018                	; #4120
   805fc:	f2a7e402 	movk	x2, #0x3f20, lsl #16
   80600:	d2820004 	mov	x4, #0x1000                	; #4096
   80604:	f2a7e404 	movk	x4, #0x3f20, lsl #16
   80608:	528001a5 	mov	w5, #0xd                   	; #13
   8060c:	d503201f 	nop
   80610:	7100283f 	cmp	w1, #0xa
   80614:	54000160 	b.eq	80640 <uart_puts+0x50>  ; b.none
   80618:	38401403 	ldrb	w3, [x0], #1
   8061c:	d503201f 	nop
   80620:	d503201f 	nop
   80624:	b9400041 	ldr	w1, [x2]
   80628:	372fffc1 	tbnz	w1, #5, 80620 <uart_puts+0x30>
   8062c:	b9000083 	str	w3, [x4]
   80630:	39400001 	ldrb	w1, [x0]
   80634:	35fffee1 	cbnz	w1, 80610 <uart_puts+0x20>
   80638:	d65f03c0 	ret
   8063c:	d503201f 	nop
   80640:	d503201f 	nop
   80644:	b9400041 	ldr	w1, [x2]
   80648:	372fffc1 	tbnz	w1, #5, 80640 <uart_puts+0x50>
   8064c:	b9000085 	str	w5, [x4]
   80650:	17fffff2 	b	80618 <uart_puts+0x28>
   80654:	d503201f 	nop
   80658:	d503201f 	nop
   8065c:	d503201f 	nop

0000000000080660 <uart_hex>:
   80660:	d2820302 	mov	x2, #0x1018                	; #4120
   80664:	f2a7e402 	movk	x2, #0x3f20, lsl #16
   80668:	d2820005 	mov	x5, #0x1000                	; #4096
   8066c:	f2a7e405 	movk	x5, #0x3f20, lsl #16
   80670:	52800383 	mov	w3, #0x1c                  	; #28
   80674:	528006e7 	mov	w7, #0x37                  	; #55
   80678:	52800606 	mov	w6, #0x30                  	; #48
   8067c:	d503201f 	nop
   80680:	1ac32401 	lsr	w1, w0, w3
   80684:	12000c21 	and	w1, w1, #0xf
   80688:	7100243f 	cmp	w1, #0x9
   8068c:	1a8680e4 	csel	w4, w7, w6, hi  ; hi = pmore
   80690:	0b010084 	add	w4, w4, w1
   80694:	d503201f 	nop
   80698:	d503201f 	nop
   8069c:	b9400041 	ldr	w1, [x2]
   806a0:	372fffc1 	tbnz	w1, #5, 80698 <uart_hex+0x38>
   806a4:	b90000a4 	str	w4, [x5]
   806a8:	51001063 	sub	w3, w3, #0x4
   806ac:	3100107f 	cmn	w3, #0x4
   806b0:	54fffe81 	b.ne	80680 <uart_hex+0x20>  ; b.any
   806b4:	d65f03c0 	ret

   ;;; 0x806b8-0x806e7: (48 bytes):  "Unable to set screen resolution to 1024x768x32"
   ;;; 0x806e8-0x866e7: (24 Kb):     homer picture in GIMP header image file format (RGB)
   ;;; 0x866e8-0x866ef: (8 bytes):   < --- purpose unknown --- >
   ;;; 0x866f0-0x866f7: (8 bytes):   framebuffer address
   ;;; 0x866f8-0x866fb: (4 bytes):   framebuffer pitch (bytes per line)
   ;;; 0x866fc-0x866ff: (4 bytes):   screen height
   ;;; 0x86700-0x86703: (4 bytes):   screen width
   ;;; 0x86704-0x8670f: (12 bytes):  < --- purpose unknown --- >
   ;;; 0x86710-0x8679b: (140 bytes): framebuffer mailbox request
   ;;; 0x8679c-0x8679f: (4 bytes):   < --- purpose unknown --- >
```

## 2.3 Render updated ZX Spectrum +2/+3 main menu

After that is done, my next goal will be to render an updated version of the
classic main menu screen:

![ZX Spectrum screenshot](spectrum_+2A_menu.gif?raw=true "ZX Spectrum
screenshot")

Logically it isn't the most important step to achieve, but the reason to do
this first is motivational.  It will _feel_ like I've made a lot of progress if
the menu is displayed, even if it isn't functional.

I might add some menu options, and adjust the relative size of the menu in
relation to the screen size (or even provide keyboard shortcuts to change the
size dynamically).

## 2.4 Get JTAG working

After this, I'd like to get JTAG debugging working, so that I can debug the
kernel builds running on the RPi directly from my Mac. I have not yet purchased
any JTAG equipment.

## 2.5 Port ZX Spectrum 48K ROM

After this I'll begin the task of porting the ZX Spectrum +2/+3 ROMs, starting
with the 16K ROM which is shared with the ZX Spectrum 48K.

This [online
copy](http://www.primrosebank.net/computers/zxspectrum/docs/CompleteSpectrumROMDisassemblyThe.pdf)
of _The Complete Spectrum ROM Disassembly_ should aid the porting process.

## 2.6 Port remaining ZX Spectrum +2/+3 ROMs

Once this is done, I intend to port the remaining ROMs, using [this disassembly
guide](http://www.fruitcake.plus.com/Sinclair/Spectrum128/ROMDisassembly/Spectrum128ROMDisassembly4.htm)
to help me.

# 3. My Setup

I have purchased the following items:

1. Two [Raspberry Pi 3B](https://www.amazon.de/gp/product/B01CD5VC92)s
2. [Apple
   iMac](https://www.amazon.de/Apple-iMac-Intel-Quad-Core-Fusion/dp/B071WP4851)
(approximate version)
3. [ZX Spectrum ULA book](https://www.amazon.de/gp/product/0956507107)
4. [Raspberry Pi Assembly Language RISC OS Beginners (Hands On
   Guide)](https://www.amazon.de/Raspberry-Assembly-Language-Beginners-English-ebook/dp/B00IIF8W1S)
5. [The Complete Spectrum ROM
   Disassembly](https://www.amazon.de/Complete-Spectrum-ROM-Disassembly-Logan/dp/0861611160)
6. 2 [Aukru Gear Cable Micro USB Charging cable with switch](https://www.amazon.de/gp/product/B01F52E5GC)es
7. [DSD Tech 4 Pin Dupont Cable USB to TTL Serial Converter
   CP2102](https://www.amazon.de/gp/product/B072K3Z3TL)
8. [iLEPO Smart USB Charger](https://www.amazon.de/dp/B079FRHS46)
9. [FTDI C232HM-DDHSL-0 JTAG device](https://www.mouser.de/ProductDetail/ftdi/c232hm-ddhsl-0/?qs=EB8w3yL7SqMfAQpmyuyp%252bw==&countrycode=DE)

# 4. Contributing

Bare metal development and ARM Assembly are new for me. This project will be a
vehicle for me, and hopefully others too, to learn about kernel development in
ARM Assembly.  If you would like to get involved, please do join the
`#spectrum4` IRC channel on `chat.freenode.net`.

I will document my progress as I go along, so if you have knowledge that might
help me overcome problems, I'd be very happy to hear from you.

To start with, I'm providing some links to help me track the web content which
should help me work on this progress (see below).

# 5. RPi 3B Bootloading

In order to avoid needing to physically remove the SD card on the RPi 3B every
time you make changes to the spectrum4 kernel during development, it is
advisable to serve the operating system over your local network from another
computer. In my case, this meant either serving them from my Mac, or serving
them from a second Raspberry Pi.

## 5.1 Option 1 - RPi 3B Bootloading From Another RPi Running TFTP Server

I have a second RPi 3B which I have set up as a TFTP server, loosely following
[this
guide](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net_tutorial.md).
At the time of writing, this guide is a little out of date (see e.g. [this
Github
issue](https://github.com/raspberrypi/documentation/issues/1006#issue-371950683)).
I will see if I can make a PR (rather than an issue) to address the issues I
found with it.

For example, the guide advises that on the RPi 3B, one can skip the sections
_Client configuration_ and _Program USB boot mode_. This was not my experience,
and I indeed needed to set the USB boot mode in order for TFTP booting to work
(note, we actually boot over Ethernet, not over USB, so the name of this
configuration setting is a little misleading!).

The guide also covers a more complex use case than we have, which involves
serving a linux distribution. Therefore some stages of this guide are not
required. The reduced set of steps I followed in order to achieve TFTP booting
is as follows:

1. Install Raspbian on an SD card. I personally install Raspbian using my Mac
   by following the _Command line_ steps of [this
page](https://www.raspberrypi.org/documentation/installation/installing-images/mac.md).

2. Mount the SD card and add `program_usb_boot_mode=1` to the end of the
   `config.txt` file.

3. Start the Raspberry Pi, and check that the boot mode flag was set in the
One-Time-Programmable memory:

```
$ vcgencmd otp_dump | grep 17:
17:3020000a
```

If it wasn't successful, you will likely get the result `17:1020000a`. That is
no good, perhaps try another reboot, and double check `/boot/config.txt`
contains your change.

4. Remove the line you added to `/boot/config.txt` and save.

5. Shut down the RPi.

6. Remove the SD card.

7. Place the Raspberry Pi somewhere safe. It will be the Raspberry Pi that will
   run spectrum4! The other raspberry pi is the one that will serve the
   spectrum4 images to it.

8. Put the same SD card in the second Raspberry Pi, and start it up.

9. Update system packages (`sudo apt-get update && sudo apt-get -y upgrade`).

10. Configure a static IP:

```
echo -e "\\n#### Set static IP for TFTP booting\\ninterface eth0\\nstatic ip_address=$(ip -4 addr show dev eth0 | grep inet | awk '{print $2}')\\nstatic routers=$(ip route | grep default | awk '{print $3}')\\nstatic domain_name_servers=$(ip route | grep default | awk '{print $3}')" | tee -a /etc/dhcpcd.conf
```

11. Install `dnsmasq` and `tcpdump`

```
sudo apt-get install -y dnsmasq tcpdump
```

12. Stop dnsmasq breaking DNS resolving:

```
sudo rm /etc/resolvconf/update.d/dnsmasq
```

13. Let's run an `ssh` daemon in order that we can `scp` files to the Raspberry Pi.

```
sudo touch /boot/ssh
sudo reboot
```

14. Start tcpdump so you can search for DHCP packets from the client Raspberry Pi:

```
sudo tcpdump -i eth0 port bootpc
```

15. Connect the other Raspberry Pi to your network (without an SD card
    inserted!) and power it on. Check that the LEDs illuminate on the client
    after around 10 seconds, then you should get a packet from the client
    `DHCP/BOOTP, Request from ...`

```
IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from b8:27:eb...
```

16. Now we need to modify the dnsmasq configuration to enable DHCP to reply to the
device. Press `Ctrl+C` on the keyboard to exit the tcpdump program, then run
the following to replace the contents of `/etc/dnsmasq.conf`:

```
echo -e "port=0\\ndhcp-range=$(ip -4 addr show dev eth0 | grep inet | awk '{print $4}'),proxy\\nlog-dhcp\\nenable-tftp\\ntftp-root=/tftpboot\\npxe-service=0,\"Raspberry Pi Boot\"" | sudo tee /etc/dnsmasq.conf
```

17. Now create a `/tftpboot` directory:

```
sudo mkdir /tftpboot
sudo chmod 777 /tftpboot
sudo systemctl enable dnsmasq.service
sudo systemctl restart dnsmasq.service
```

18. Now monitor the dnsmasq log:

```
tail -F /var/log/daemon.log
```

19. If your other Raspberry Pi isn't already running, then turn it on (but keep
    your display connected to the current Raspberry Pi). You should see
    something like this appear in the dnsmasq logs:

```
raspberrypi dnsmasq-tftp[1903]: file /tftpboot/bootcode.bin not found
```

Use `Ctrl+C` to exit the monitoring state.


20. Now we just need to copy some files into the `/tftpboot` directory. A
    simple and small example is the Peter Lemon Julia set animation.

```
curl -#L 'https://github.com/raspberrypi/firmware/raw/abfb4be3e1b5836e1ffd96de4ce499406ec9dbb8/boot/bootcode.bin' > /tftpboot/bootcode.bin
curl -#L 'https://github.com/raspberrypi/firmware/raw/abfb4be3e1b5836e1ffd96de4ce499406ec9dbb8/boot/start.elf' > /tftpboot/start.elf
curl -#L 'https://github.com/PeterLemon/RaspberryPi/raw/7130e72637d08b1976512bd60a372acb9b458310/boot/config.txt' > /tftpboot/config.txt
curl -#L 'https://github.com/PeterLemon/RaspberryPi/raw/7130e72637d08b1976512bd60a372acb9b458310/NEON/Fractal/Julia/kernel7.img' > /tftpboot/kernel7.img
```

21. Turn the SD-card-less RPi off, connect it to a display with an HDMI cable,
    and then turn it back on again. You should see a fractal animation based on
    the Julia Set.

## 5.2 Option 2 - RPi 3B Bootloading From A MacOS TFTP Server

I haven't got this working yet.

## 5.3 Option 3 - RPi 3B Bootloading From A Docker Container Running A TFTP Server

I haven't tried this yet, is pretty adventurous.

## 5.4 Option 4 - RPi 3B Bootloading From A Windows TFTP Server

I haven't tried this yet either, I don't currently have a Windows installation
to try this out with.

# 6. Links

## 6.1 RPi Bare Metal RPi Development

1. [David Welch - Bare metal guide](https://github.com/dwelch67/raspberrypi/tree/master/baremetal)
2. [CS107e - Stanford's introductory course to bare metal programming on Raspberry Pi.](https://cs107e.github.io/)
3. [Peter Lemon - RPi bare metal tutorials](https://github.com/PeterLemon/RaspberryPi)
4. [Cambridge University - Baking Pi](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/)
5. [Mauri de Souza Nunes - Baking Pi for RPi 3B](https://github.com/mauri870/baking-pi)
6. [eLinux RPi hardware page](https://elinux.org/RPi_Hardware)
7. [BCM2837 help page](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2837/README.md)
8. [OSDev.org - Raspberry Pi Bare Bones](https://wiki.osdev.org/Raspberry_Pi_Bare_Bones#Updated_Support_for_AArch64_.28raspi2.2C_raspi3.29)
9. [The Raspberry Pi UARTs](https://www.raspberrypi.org/documentation/configuration/uart.md)
10. [Raspberry Pi bare metal/assembly forum](https://www.raspberrypi.org/forums/viewforum.php?f=72)
11. [Adam Ransom - Hello World RPi 3B](https://adamransom.github.io/posts/raspberry-pi-bare-metal-part-1.html)
12. [Zoltan Baldaszti - Bare Metal Programming on Raspberry Pi 3](https://github.com/bztsrc/raspi3-tutorial)
13. [Sergey Matyukevich - Learning operating system development using Linux kernel and Raspberry Pi](https://github.com/s-matyukevich/raspberry-pi-os)
14. [Leon de Boer - Baremetal Raspberry Pi](https://github.com/LdB-ECM/Raspberry-Pi)
15. [ICTeam 28 - PiFox: 3D rail shooter written in ARM assembly](https://github.com/ICTeam28/PiFox)
16. [Tetris-Duel-Team - Multiplayer Tetris for Raspberry Pi (in bare metal assembly)](https://github.com/Tetris-Duel-Team/Tetris-Duel)
17. [Jake Sandler - Building an Operating System for the Raspberry Pi](https://jsandler18.github.io)
18. [Brian Sidebotham - Raspberry-Pi Bare Metal Tutorial](https://github.com/BrianSidebotham/arm-tutorial-rpi)
19. [Miro Samek - Building Bare-Metal ARM Systems with GNU](https://www.embedded.com/design/mcus-processors-and-socs/4007119/Building-Bare-Metal-ARM-Systems-with-GNU-Part-1--Getting-Started)
20. [Andre Richter - Bare Metal Rust Programming on Raspberry Pi 3](https://github.com/rust-embedded/rust-raspi3-tutorial)
21. [Linuxhit - Raspberry Pi PXE Boot – Network booting a Pi 4 without an SD card](https://linuxhit.com/raspberry-pi-pxe-boot-netbooting-a-pi-4-without-an-sd-card/)
22. [William Lam - Two methods to network boot Raspberry Pi 4](https://williamlam.com/2020/07/two-methods-to-network-boot-raspberry-pi-4.html)
23. [Adam Greenwood-Byrne - Writing a “bare metal” operating system for Raspberry Pi 4](https://www.rpi4os.com/)

## 6.2 RPi Assembly under Linux

1. [Robert G. Plantz - Introduction to Computer Organization: ARM Assembly Language Using the Raspberry Pi](http://bob.cs.sonoma.edu/IntroCompOrg-RPi/intro-co-rpi.html)

## 6.3 ARM Cortex A53 Reference

1. [ARM Cortex-A53 MPCore Processor Technical Reference
   Manual](https://developer.arm.com/docs/ddi0500/j)
2. [The ARMv8 Instruction Set
   Overview](https://www.element14.com/community/servlet/JiveServlet/previewBody/41836-102-1-229511/ARM.Reference_Manual.pdf)
3. [The A64 instruction
   set](https://static.docs.arm.com/100898/0100/the_a64_Instruction_set_100898_0100.pdf)
4. [The armasm User
   Guide](https://static.docs.arm.com/dui0801/i/DUI0801I_armasm_user_guide.pdf?_ga=2.140209011.1305908269.1541444114-1114139748.1539604101)
5. [The A64 Instruction Set Reference](https://developer.arm.com/docs/100076/latest/part-d-a64-instruction-set-reference)
6. [ARM Cortex-A Series Programmer's Guide for ARMv8-A](http://infocenter.arm.com/help/topic/com.arm.doc.den0024a/DEN0024A_v8_architecture_PG.pdf)
7. [A Guide to ARM64 / AArch64 Assembly on Linux with Shellcodes and Cryptography](https://modexp.wordpress.com/2018/10/30/arm64-assembly/)
8. [How to handle stripped binaries with GDB](https://reverseengineering.stackexchange.com/questions/1935/how-to-handle-stripped-binaries-with-gdb-no-source-no-symbols-and-gdb-only-sho/1936#1936?newreg=7c1b23ce97724460bfb5e56a508bfb5d)
9. [ARM Processor Cortex A53 MPCore Product Revision r0 Software Developers Errata Notice](https://documentation-service.arm.com/static/5fa29fddb209f547eebd361d)
10. [Bare-metal Boot Code for ARMv8-A Processors](https://developer.arm.com/documentation/dai0527/a/)
11. [ARM Trusted Firmware](https://github.com/ARM-software/arm-trusted-firmware)

## 6.4 BCM283x Reference

1. [BCM2835 ARM Peripherals](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf)
2. [BCM2836 ARM Peripherals](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2836/QA7_rev3.4.pdf)
3. [BCM2837 ARM Peripherals](https://github.com/raspberrypi/documentation/files/1888662/BCM2837-ARM-Peripherals.-.Revised.-.V2-1.pdf)


## 6.5 VideoCore IV

1. [Herman Hermitage - Tools and information for the Broadcom VideoCore IV (RaspberryPi)](https://github.com/hermanhermitage/videocoreiv)
2. [VideoCore® IV 3D - Architecture Reference Guide](https://docs.broadcom.com/docs/12358545)

## 6.6 RPi JTAG

1. [Remote Debugging of Raspberry Pi with JTAG interface](https://wiki.aalto.fi/download/attachments/84747235/rpi_jtag.pdf?version=3&modificationDate=1386972920322&api=v2)
2. [JTag for Pi 3 - David Welch advice](https://www.raspberrypi.org/forums/viewtopic.php?t=202540)
3. [SUSE Blog - Debugging Raspberry Pi 3 with JTAG](https://www.suse.com/c/debugging-raspberry-pi-3-with-jtag/)
4. [dwelch67 armjtag folder](https://github.com/dwelch67/raspberrypi/tree/master/armjtag)
5. [Daniel Krebs - JTAG and bare metal on Raspberry Pi 3](https://github.com/daniel-k/rpi3-aarch64-jtag)
6. [Mete Balci - Bare Metal Raspberry Pi 3B+: JTAG](https://metebalci.com/blog/bare-metal-raspberry-pi-3b-jtag/)

## 6.7 USB Keyboard

See [USB subfolder](USB/README.md) of this project.

## 6.8 ZX Spectrum

1. [Sinclair ZX Spectrum - BASIC Programming](http://www.worldofspectrum.org/ZXBasicManual/)
2. [World of Spectrum - Documentation](https://www.worldofspectrum.org/documentation.html)
3. [Interrupts](http://www.breakintoprogram.co.uk/computers/zx-spectrum/interrupts)
4. [ZXBaremulator](http://zxmini.speccy.org/)
5. [SkoolKit disassemblies](http://skoolkit.ca/?page_id=1016)
6. [Sergey Kiselev - Building ZX Spectrum Clone - Harlequin](http://www.malinov.com/Home/sergey-s-blog/buildingzxspectrumclone-harlequin-part1)
7. [Matt Westcott (Gasman) - Channels and streams](https://faqwiki.zxnet.co.uk/wiki/Channels_and_streams)

## 6.9 Z80

1. [Steve Ciarcia - Build Your Own Z80 Computer](http://www.pestingers.net/pdfs/other-computers/build-your-own-z80.pdf)
2. [Z80 Info](http://z80.info/)
3. [Ben Eater - Build an 8-bit computer from scratch](https://eater.net/8bit/)
4. [Robin Mitchell - How to Build a Z80 Computer](https://maker.pro/pic/projects/z80-computer-project-part-1-the-cpu)
5. [Z80 CPU User Manual UM008011-0816](http://www.zilog.com/force_download.php?filepath=YUhSMGNEb3ZMM2QzZHk1NmFXeHZaeTVqYjIwdlpHOWpjeTk2T0RBdlZVMHdNRGd3TG5Ca1pnPT0=)
6. [Channels and streams](https://faqwiki.zxnet.co.uk/wiki/Channels_and_streams)
7. [ZX Art](https://zxart.ee/eng/mainpage/) (not really useful, but pretty cool!)

## 6.10 AY-3-8910 (spectrum sound chip)

1. [AY-3-8910 FPGA](https://github.com/FPGA-Code/AS-2518-51_snd/blob/master/ay-3-8910.Vhd)

## 6.11 Miscellaneous

1. [DSD Tech 4 Pin Dupont Cable USB to TTL Serial Converter CP2102
   Drivers](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)
2. [Viewing SSID from macOS](https://stackoverflow.com/questions/4481005/get-wireless-ssid-through-shell-script-on-mac-os-x)
3. [Enabling WiFi on rpi over serial connection](https://bhattigurjot.wordpress.com/2013/10/26/connect-to-wi-fi-network-through-ubuntu-terminal/)
   Note, run the above as root. May need to also run `sudo rfkill unblock all`.
