This directory contains my own notes on the Spectrum 128K ROMs. The original
versions can be found in the /zxspectrum_roms directory of this repo.




### RST $00 — Reset Machine


L0000
* Disable interrupts: stops keyboard updates.  RPi: need to understand if USB keyboard input will be polled or managed via interrupts too like the spectrum.
L0004
* Sleep 0.2s. RPi: not needed
* Jump to "Reset Routine (RST $00 Continuation, Part 1)"

### RST $10 — Print A Character

L0010
* Call ROM1 corresponding routing. RPi: duplication not needed, just implement ROM1 version.

### RST $18 — Collect A Character

L0018
* Call ROM1 corresponding routing. RPi: duplication not needed, just implement ROM1 version.

### RST $20 — Collect Next Character

L0020
* Call ROM1 corresponding routing. RPi: duplication not needed, just implement ROM1 version.

### RST $28 — Call Routine in ROM 1

L0028
* Not needed as we don't need to page memory in/out in RPi.
* Call RESTART ROUTINES — PART 2

### MASKABLE INTERRUPT ROUTINE

L0038
* Call interuppt handling routine from ROM 1. Not needed (I _think_) since we just need to implement ROM1 version.

### ERROR HANDLER ROUTINES — PART 1

L004A
* Disable interrupts
* OUT ($7FFD),0 <- pages RAM bank 0 into $C000 / SCREEN 0 (regular screen bank 5) / ROM 0 (128K editor). RPi: only relevant part here is pointing framebuffer at regular screen.
* Store value in BANK_M. RPi: needed if we want to keep a copy of the framebuffer address (but maybe we can query gpu?).
* Enable interrupts
* Reset ERR_NR to 0 (no error)
* Call ERROR HANDLER ROUTINES — PART 3

### RESTART ROUTINES — PART 2

## RAM Routines

### Swap to Other ROM (copied to $5B00)

L005C
* Not needed

### Return to Other ROM Routine (copied to $5B14)

L007F
* Not needed

### Error Handler Routine (copied to $5B1D)

L0088
* Not needed

### 'P' Channel Input Routine (copied to $5B2F)

L009A
* Printer input routine => Error?

### 'P' Channel Output Routine (copied to $5B34)

L009F
* Send printer output to UART?

### 'P' Channel Exit Routine (copied to $5B4A)

L00B5
* ?

### ERROR HANDLER ROUTINES — PART 2

L00C3
* Call Subroutine - not needed

## INITIALISATION ROUTINES — PART 1

### Reset Routine (RST $00 Continuation, Part 1)

L00C7
* Clear RAM (set to $FF, check bits all set, then set to $00)
* Reset keypad (not needed)
* Jump to "Reset Routine (RST $00 Continuation, Part 2)"

### ROUTINE VECTOR TABLE

L0100
Jump table for various routines

## INITIALISATION ROUTINES — PART 2

### Fatal RAM Error

L0131
* Not needed (I guess)
* Sets border colour, based on which RAM bank is floored

### Reset Routine (RST $00 Continuation, Part 2)

By the time execution reaches here, the following memory has been initialised:
ram0: all zeros
ram1: all zeros
ram2: all zeros
ram3: all zeros
ram4: all zeros
ram5: all zeros
ram6: all zeros
ram7: all zeros


L0137
* Initialise sound chip
* Copy paging routines to RAM (not needed)
5B00 -> 5B57 + 5B5D
* Initialise stack pointer
5BFF (ram5:1BFF)
* Initialise ram disk
5B83/4 = EBEC (ram5:1B83/4)
ram7:2BF6/7/8 = 00/C0/00
Stack corruption: 5BFB/D/E
ram5:5B85/6/7 = EC/2B/01
* Page in logical bank 5 (physical bank 0) to $C000 - not needed
5CB4/5
* Set P_RAMT to $FFFF (ramtop) - i think because P_RAMT is used by ROM1 (48k interpreter) and it also worked with 16K Spectrum which had $7FFF for ramptop(??)
* chr 144 - 164 are user defined graphics, initially copied from A-U
  see http://www.worldofspectrum.org/ZXBasicManual/zxmanappa.html
  and https://k1.spdns.de/Vintage/Sinclair/82/Sinclair%20ZX%20Spectrum/BASIC%20Programming%20Manual/zxmanchap14.html
  copy them to top of RAM (ending at $FFFF)
* initialise UDG (pointer to start of user defined graphics)
* initialise PIP and RASP
* put RAMPTOP below UDG

Entry point for NEW

L019D
* initialise CHARS system var (start of chars char 0)
* set stack pointer as one higher than RAMPTOP (i.e. where UDG starts - so stack grows underneath UDGs)
* set interrupt mode 1 - interrupts every screen refresh calling $0038 (see http://www.breakintoprogram.co.uk/computers/zx-spectrum/interrupts) - calls Maskable interrupt routine, switching in ROM1 and then ROM0 again. This routine reads keyboard.
* set IY (top of system vars)
* set 128K mode sys var (bit 4 of FLAGS)
* Enable interrupts
* Initialise RS232 baud rate (9600)
* Initialise RS232 settings
* Initialise printer width (80 chars)
