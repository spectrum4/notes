# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# ------------------
# RAM Disk Catalogue
# ------------------
#
# Both the catalogue and files of the RAMDISK are contained in the RAMDISK
# section (from RAMDISK to RAMDISK+RAMDISKSIZE):
#   The catalogue is located at the top of RAMDISK section and grows downwards
#   The files are located at the bottom of RAMDISK and grow upwards
#
# Each catalogue entry contains 96 (0x60) bytes:
#   Bytes 0x00-0x3F: Filename.
#   Bytes 0x40-0x47: Start address of file
#   Bytes 0x48-0x4F: Length of file
#   Bytes 0x50-0x57: End address of file (used as current position indicator when loading/saving).
#   Bytes 0x58-0x5F: Flags:
#                     Bit 0:     1=Entry requires updating.
#                     Bits 1-63: Not used (always hold 0).
#
# There is no heap and no malloc/free functions in spectrum4, when a file is
# deleted, any file which is stored after it is relocated to a lower memory
# address to remove the gap of the file contents, and the catalogue entries are
# moved to a higher memory address to remove the gap in the catalogue. This is
# clearly suboptimal, but is implemented this way to match the original
# spectrum. This can be later improved once things are working.
#
# A file consists of a 32 byte header (256 bits) followed by the data for the file. The header bytes
# have the following meaning:
#   Bytes 0x00-0x07: FLAGS
#                      Bits 0-15:  File type - 0x00=Program, 0x01=Numeric array, 0x02=Character array, 0x03=Code/Screen$.
#                      Bits 16-63: Auto-run line number for a program (0xffffffffffff if no auto-run).
#   Bytes 0x08-0x0F: Length of program/code block/screen$/array
#   Bytes 0x10-0x17: Start of code block/screen$
#   Bytes 0x18-0x1F: Offset to the variables (i.e. length of program) if a program. For an array, 0x18 holds the variable name.




.arch armv8-a
.cpu cortex-a53
.global RAMDISK


#### I'm assuming this can't be commented out, but I should probably try once, just to see
.global _start


.bss

# ------------------------------------------------------------------------------
# System variables that are initialised with zeros
# ------------------------------------------------------------------------------

# --------------------
# New System Variables
# --------------------
# These are held in the old ZX Printer buffer at $5B00-$5BFF.
# Note that some of these names conflict with the system variables used by the ZX Interface 1.

BANK_M:  .space 1                           //   EQU 0x5B5C    Copy of last byte output to I/O port 0x7FFD.
RAMERR:  .space 1                           //   EQU 0x5B5E    Error number for use by RST 0x08 held in RAMRST.
BAUD:    .space 2                           //   EQU 0x5B5F    Baud rate timing constant for RS232 socket. Default value of 11. [Name clash with ZX Interface 1 system variable at 0x5CC3]
SERFL:   .space 2                           //   EQU 0x5B61    Second character received flag:
                                            //                   Bit 0   : 1=Character in buffer.
                                            //                   Bits 1-7: Not used (always hold 0).
                                            //   EQU 0x5B62    Received Character.
COL:     .space 1                           //   EQU 0x5B63    Current column from 1 to WIDTH. Set to 0 by NEW command.
WIDTH:   .space 1                           //   EQU 0x5B64    Paper column width. Default value of 80. [Name clash with ZX Interface 1 Edition 2 system variable at 0x5CB1]
TVPARS:  .space 1                           //   EQU 0x5B65    Number of inline parameters expected by RS232 (e.g. 2 for AT).
FLAGS3:  .space 1                           //   EQU 0x5B66    Flags: [Name clashes with the ZX Interface 1 system variable at 0x5CB6]
                                            //                   Bit 0: 1=BASIC/Calculator mode, 0=Editor/Menu mode.
                                            //                   Bit 1: 1=Auto-run loaded BASIC program. [Set but never tested by the ROM]
                                            //                   Bit 2: 1=Editing RAM disk catalogue.
                                            //                   Bit 3: 1=Using RAM disk commands, 0=Using cassette commands.
                                            //                   Bit 4: 1=Indicate LOAD.
                                            //                   Bit 5: 1=Indicate SAVE.
                                            //                   Bit 6; 1=Indicate MERGE.
                                            //                   Bit 7: 1=Indicate VERIFY.
N_STR1:  .space 10                          //   EQU 0x5B67    Used by RAM disk to store a filename. [Name clash with ZX Interface 1 system variable at 0x5CDA]
                                            //                 Used by the renumber routine to store the address of the BASIC line being examined.
HD_00:   .space 1                           //   EQU 0x5B71    Used by RAM disk to store file header information (see RAM disk Catalogue section below for details). [Name clash with ZX Interface 1 system variable at 0x5CE6]
                                            //                 Used as column pixel counter in COPY routine.
                                            //                 Used by FORMAT command to store specified baud rate.
                                            //                 Used by renumber routine to store the number of digits in a pre-renumbered line number reference. [Name clash with ZX Interface 1 system variable at 0x5CE7]
HD_0B:   .space 2                           //   EQU 0x5B72    Used by RAM disk to store header info - length of block.
                                            //                 Used as half row counter in COPY routine.
                                            //                 Used by renumber routine to generate ASCII representation of a new line number.
HD_0D:   .space 2                           //   EQU 0x5B74    Used by RAM disk to store file header information (see RAM disk Catalogue section below for details). [Name clash with ZX Interface 1 system variable at 0x5CE9]
HD_0F:   .space 2                           //   EQU 0x5B76    Used by RAM disk to store file header information (see RAM disk Catalogue section below for details). [Name clash with ZX Interface 1 system variable at 0x5CEB]
                                            //                 Used by renumber routine to store the address of a referenced BASIC line.
HD_11:   .space 2                           //   EQU 0x5B78    Used by RAM disk to store file header information (see RAM disk Catalogue section below for details). [Name clash with ZX Interface 1 system variable at 0x5CED]
                                            //                 Used by renumber routine to store existing VARS address/current address within a line.
SC_00:   .space 1                           //   EQU 0x5B7A    Used by RAM disk to store alternate file header information (see RAM disk Catalogue section below for details).
SC_0B:   .space 2                           //   EQU 0x5B7B    Used by RAM disk to store alternate file header information (see RAM disk Catalogue section below for details).
SC_0D:   .space 2                           //   EQU 0x5B7D    Used by RAM disk to store alternate file header information (see RAM disk Catalogue section below for details).
SC_0F:   .space 2                           //   EQU 0x5B7F    Used by RAM disk to store alternate file header information (see RAM disk Catalogue section below for details).
OLDSP:   .space 2                           //   EQU 0x5B81    Stores old stack pointer when TSTACK in use.
SFNEXT:  .space 8                           //   EQU 0x5B83    End of RAM disk catalogue marker. Pointer to first empty catalogue entry.
SFSPACE: .space 8                           //   EQU 0x5B85    Number of bytes free in RAM disk
ROW01:   .space 1                           //   EQU 0x5B88    Stores keypad data for row 3, and flags:
                                            //                   Bit 0   : 1=Key '+' pressed.
                                            //                   Bit 1   : 1=Key '6' pressed.
                                            //                   Bit 2   : 1=Key '5' pressed.
                                            //                   Bit 3   : 1=Key '4' pressed.
                                            //                   Bits 4-5: Always 0.
                                            //                   Bit 6   : 1=Indicates successful communications to the keypad.
                                            //                   Bit 7   : 1=If communications to the keypad established.
ROW23:   .space 1                           //   EQU 0x5B89    Stores keypad key press data for rows 1 and 2:
                                            //                   Bit 0: 1=Key ')' pressed.
                                            //                   Bit 1: 1=Key '(' pressed.
                                            //                   Bit 2: 1=Key '*' pressed.
                                            //                   Bit 3: 1=Key '/' pressed.
                                            //                   Bit 4: 1=Key '-' pressed.
                                            //                   Bit 5: 1=Key '9' pressed.
                                            //                   Bit 6: 1=Key '8' pressed.
                                            //                   Bit 7: 1=Key '7' pressed.
ROW45:   .space 1                           //   EQU 0x5B8A    Stores keypad key press data for rows 4 and 5:
                                            //                   Bit 0: Always 0.
                                            //                   Bit 1: 1=Key '.' pressed.
                                            //                   Bit 2: Always 0.
                                            //                   Bit 3: 1=Key '0' pressed.
                                            //                   Bit 4: 1=Key 'ENTER' pressed.
                                            //                   Bit 5: 1=Key '3' pressed.
                                            //                   Bit 6: 1=Key '2' pressed.
                                            //                   Bit 7: 1=Key '1' pressed.
SYNRET:  .space 2                           //   EQU 0x5B8B    Return address for ONERR routine.
LASTV:   .space 5                           //   EQU 0x5B8D    Last value printed by calculator.
RNLINE:  .space 2                           //   EQU 0x5B92    Address of the length bytes in the line currently being renumbered.
RNFIRST: .space 2                           //   EQU 0x5B94    Starting line number when renumbering. Default value of 10.
RNSTEP:  .space 2                           //   EQU 0x5B96    Step size when renumbering. Default value of 10.
STRIP1:  .space 32                          //   EQU 0x5B98    Used as RAM disk transfer buffer (32 bytes to 0x5BB7).
                                            //                 Used to hold Sinclair stripe character patterns (16 bytes to 0x5BA7).
                                            //                 ...

# =========================
# Standard System Variables
# =========================
# These occupy addresses $5C00-$5CB5.

KSTATE:    .space 8                         // 5C00   IY-$3A   Used in reading the keyboard.
LASTK:     .space 1                         // 5C08   IY-$32   Stores newly pressed key.
REPDEL:    .space 1                         // 5C09   IY-$31   Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
REPPER:    .space 1                         // 5C0A   IY-$30   Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
DEFADD:    .space 2                         // 5C0B   IY-$2F   Address of arguments of user defined function (if one is being evaluated), otherwise 0.
K_DATA:    .space 1                         // 5C0D   IY-$2D   Stores second byte of colour controls entered from keyboard.
TVDATA:    .space 2                         // 5C0E   IY-$2C   Stores bytes of colour, AT and TAB controls going to TV.
STRMS:     .space 38                        // 5C10   IY-$2A   Addresses of channels attached to streams.
CHARS:     .space 8                         // 5C36   IY-$04   256 less than address of character set, which starts with ' ' and carries on to '©'.
RASP:      .space 1                         // 5C38   IY-$02   Length of warning buzz.
PIP:       .space 1                         // 5C39   IY-$01   Length of keyboard click.
ERR_NR:    .space 1                         // 5C3A   IY+$00   1 less than the report code. Starts off at 255 (for -1) so 'PEEK 23610' gives 255.
FLAGS:     .space 1                         // 5C3B   IY+$01   Various flags to control the BASIC system:
                                            //                   Bit 0: 1=Suppress leading space.
                                            //                   Bit 1: 1=Using printer, 0=Using screen.
                                            //                   Bit 2: 1=Print in L-Mode, 0=Print in K-Mode.
                                            //                   Bit 3: 1=L-Mode, 0=K-Mode.
                                            //                   Bit 4: 1=128K Mode, 0=48K Mode. [Always 0 on 48K Spectrum]
                                            //                   Bit 5: 1=New key press code available in LAST_K.
                                            //                   Bit 6: 1=Numeric variable, 0=String variable.
                                            //                   Bit 7: 1=Line execution, 0=Syntax checking.
TVFLAG:    .space 1                         // 5C3C   IY+$02   Flags associated with the TV:
                                            //                   Bit 0  : 1=Using lower editing area, 0=Using main screen.
                                            //                   Bit 1-2: Not used (always 0).
                                            //                   Bit 3  : 1=Mode might have changed.
                                            //                   Bit 4  : 1=Automatic listing in main screen, 0=Ordinary listing in main screen.
                                            //                   Bit 5  : 1=Lower screen requires clearing after a key press.
                                            //                   Bit 6  : 1=Tape Loader option selected (set but never tested). [Always 0 on 48K Spectrum]
                                            //                   Bit 7  : Not used (always 0).

SYSVARS:

ERR_SP:    .space 2                         // 5C3D   IY+$03   Address of item on machine stack to be used as error return.
LISTSP:    .space 2                         // 5C3F   IY+$05   Address of return address from automatic listing.
MODE:      .space 1                         // 5C41   IY+$07   Specifies cursor type:
                                            //                   $00='L' or 'C'.
                                            //                   $01='E'.
                                            //                   $02='G'.
                                            //                   $04='K'.
NEWPPC:    .space 2                         // 5C42   IY+$08   Line to be jumped to.
NSPPC:     .space 1                         // 5C44   IY+$0A   Statement number in line to be jumped to.
PPC:       .space 2                         // 5C45   IY+$0B   Line number of statement currently being executed.
SUBPPC:    .space 1                         // 5C47   IY+$0D   Number within line of statement currently being executed.
BORDCR:    .space 1                         // 5C48   IY+$0E   Border colour multiplied by 8; also contains the attributes normally used for the lower half
                                            //                 of the screen.
E_PPC:     .space 2                         // 5C49   IY+$0F   Number of current line (with program cursor).

########################
# Pointers in the HEAP #
########################
VARS:      .space 8                         // 5C4B   IY+$11   Address of variables.
DEST:      .space 8                         // 5C4D   IY+$13   Address of variable in assignment.
CHANS:     .space 8                         // 5C4F   IY+$15   Address of channel data.
CURCHL:    .space 8                         // 5C51   IY+$17   Address of information currently being used for input and output.
PROG:      .space 8                         // 5C53   IY+$19   Address of BASIC program.
NXTLIN:    .space 8                         // 5C55   IY+$1B   Address of next line in program.
DATADD:    .space 8                         // 5C57   IY+$1D   Address of terminator of last DATA item.
E_LINE:    .space 8                         // 5C59   IY+$1F   Address of command being typed in.
K_CUR:     .space 8                         // 5C5B   IY+$21   Address of cursor.
CH_ADD:    .space 8                         // 5C5D   IY+$23   Address of the next character to be interpreted - the character after the argument of PEEK,
                                            //                 or the NEWLINE at the end of a POKE statement.
X_PTR:     .space 8                         // 5C5F   IY+$25   Address of the character after the '?' marker.
WORKSP:    .space 8                         // 5C61   IY+$27   Address of temporary work space.
STKBOT:    .space 8                         // 5C63   IY+$29   Address of bottom of calculator stack.
STKEND:    .space 8                         // 5C65   IY+$2B   Address of start of spare space.
########################

BREG:      .space 1                         // 5C67   IY+$2D   Calculator's B register.
MEM:       .space 2                         // 5C68   IY+$2E   Address of area used for calculator's memory (usually MEMBOT, but not always).
FLAGS2:    .space 1                         // 5C6A   IY+$30   Flags:
                                            //                   Bit 0  : 1=Screen requires clearing.
                                            //                   Bit 1  : 1=Printer buffer contains data.
                                            //                   Bit 2  : 1=In quotes.
                                            //                   Bit 3  : 1=CAPS LOCK on.
                                            //                   Bit 4  : 1=Using channel 'K'.
                                            //                   Bit 5-7: Not used (always 0).
DF_SZ:     .space 1                         // 5C6B   IY+$31   The number of lines (including one blank line) in the lower part of the screen.
S_TOP:     .space 2                         // 5C6C   IY+$32   The number of the top program line in automatic listings.
OLDPPC:    .space 2                         // 5C6E   IY+$34   Line number to which CONTINUE jumps.
OSPPC:     .space 1                         // 5C70   IY+$36   Number within line of statement to which CONTINUE jumps.
FLAGX:     .space 1                         // 5C71   IY+$37   Flags:
                                            //                   Bit 0  : 1=Simple string complete so delete old copy.
                                            //                   Bit 1  : 1=Indicates new variable, 0=Variable exists.
                                            //                   Bit 2-4: Not used (always 0).
                                            //                   Bit 5  : 1=INPUT mode.
                                            //                   Bit 6  : 1=Numeric variable, 0=String variable. Holds nature of existing variable.
                                            //                   Bit 7  : 1=Using INPUT LINE.
STRLEN:    .space 2                         // 5C72   IY+$38   Length of string type destination in assignment.
T_ADDR:    .space 2                         // 5C74   IY+$3A   Address of next item in syntax table.
SEED:      .space 2                         // 5C76   IY+$3C   The seed for RND. Set by RANDOMIZE.
FRAMES:    .space 3                         // 5C78   IY+$3E   3 byte (least significant byte first), frame counter incremented every 20ms.
UDG:       .space 8                         // 5C7B   IY+$41   Address of first user-defined graphic. Can be changed to save space by having fewer
                                            //                 user-defined characters.
COORDS:    .space 2                         // 5C7D   IY+$43   X-coordinate of last point plotted.
                                            // 5C7E   IY+$44   Y-coordinate of last point plotted.
P_POSN:    .space 1                         // 5C7F   IY+$45   33-column number of printer position.
PR_CC:     .space 2                         // 5C80   IY+$46   Full address of next position for LPRINT to print at (in ZX Printer buffer).
                                            //                 Legal values $5B00 - $5B1F. [Not used in 128K mode]
ECHO_E:    .space 2                         // 5C82   IY+$48   33-column number and 24-line number (in lower half) of end of input buffer.
DF_CC:     .space 2                         // 5C84   IY+$4A   Address in display file of PRINT position.
DF_CCL:    .space 2                         // 5C86   IY+$4C   Like DF CC for lower part of screen.
S_POSN:    .space 2                         // 5C88   IY+$4E   33-column number for PRINT position.
                                            // 5C89   IY+$4F   24-line number for PRINT position.
SPOSNL:    .space 2                         // 5C8A   IY+$50   Like S_POSN for lower part.
SCR_CT:    .space 1                         // 5C8C   IY+$52   Counts scrolls - it is always 1 more than the number of scrolls that will be done before
                                            //                 stopping with 'scroll?'.
ATTR_P:    .space 1                         // 5C8D   IY+$53   Permanent current colours, etc, as set up by colour statements.
MASK_P:    .space 1                         // 5C8E   IY+$54   Used for transparent colours, etc. Any bit that is 1 shows that the corresponding attribute
                                            //                 bit is taken not from ATTR_P, but from what is already on the screen.
ATTR_T:    .space 1                         // 5C8F   IY+$55   Temporary current colours (as set up by colour items).
MASK_T:    .space 1                         // 5C90   IY+$56   Like MASK_P, but temporary.
P_FLAG:    .space 1                         // 5C91   IY+$57   Flags:
                                            //                   Bit 0: 1=OVER 1, 0=OVER 0.
                                            //                   Bit 1: Not used (always 0).
                                            //                   Bit 2: 1=INVERSE 1, 0=INVERSE 0.
                                            //                   Bit 3: Not used (always 0).
                                            //                   Bit 4: 1=Using INK 9.
                                            //                   Bit 5: Not used (always 0).
                                            //                   Bit 6: 1=Using PAPER 9.
                                            //                   Bit 7: Not used (always 0).
MEMBOT:    .space 32                        // 5C92   IY+$58   Calculator's memory area - used to store numbers that cannot conveniently be put on the
                                            //                 calculator stack.
                                            // 5CB0   IY+$76   Not used on standard Spectrum. [Used by ZX Interface 1 Edition 2 for printer WIDTH]
RAMTOP:    .space 8                         // 5CB2   IY+$78   Address of last byte of BASIC system area.
P_RAMT:    .space 8                         // 5CB4   IY+$7A   Address of last byte of physical RAM.



# --------------------------
# Editor Workspace Variables
# --------------------------
# These occupy addresses $EC00-$FFFF in physical RAM bank 7, and form a workspace used by 128 BASIC Editor.



R0_EC00: .space 3                           //  Byte 0: Flags used when inserting a line into the BASIC program (first 4 bits are mutually exclusive).
                                            //    Bit 0: 1=First row of the BASIC line off top of screen.
                                            //    Bit 1: 1=On first row of the BASIC line.
                                            //    Bit 2: 1=Using lower screen and only first row of the BASIC line visible.
                                            //    Bit 3: 1=At the end of the last row of the BASIC line.
                                            //    Bit 4: Not used (always 0).
                                            //    Bit 5: Not used (always 0).
                                            //    Bit 6: Not used (always 0).
                                            //    Bit 7: 1=Column with cursor not yet found.
                                            //  Byte 1: Column number of current position within the BASIC line being inserted. Used when fetching characters.
                                            //  Byte 2: Row number of current position within the BASIC line is being inserted. Used when fetching characters.
R0_EC03: .space 3                           //  Byte 0: Flags used upon an error when inserting a line into the BASIC program (first 4 bits are mutually exclusive).
                                            //    Bit 0: 1=First row of the BASIC line off top of screen.
                                            //    Bit 1: 1=On first row of the BASIC line.
                                            //    Bit 2: 1=Using lower screen and only first row of the BASIC line visible.
                                            //    Bit 3: 1=At the end of the last row of the BASIC line.
                                            //    Bit 4: Not used (always 0).
                                            //    Bit 5: Not used (always 0).
                                            //    Bit 6: Not used (always 0).
                                            //    Bit 7: 1=Column with cursor not yet found.
                                            //  Byte 1: Start column number where BASIC line is being entered. Always holds 0.
                                            //  Byte 2: Start row number where BASIC line is being entered.
R0_EC06: .space 2                           //  Count of the number of editable characters in the BASIC line up to the cursor within the Screen Line Edit Buffer.
R0_EC08: .space 2                           //  Version of E_PPC used by BASIC Editor to hold last line number entered.
R0_EC0C: .space 1                           //  Current menu index.
R0_EC0D: .space 1                           //  Flags used by 128 BASIC Editor:
                                            //    Bit 0: 1=Screen Line Edit Buffer (including Below-Screen Line Edit Buffer) is full.
                                            //    Bit 1: 1=Menu is displayed.
                                            //    Bit 2: 1=Using RAM disk.
                                            //    Bit 3: 1=Current line has been altered.
                                            //    Bit 4: 1=Return to calculator, 0=Return to main menu.
                                            //    Bit 5: 1=Do not process the BASIC line (used by the Calculator).
                                            //    Bit 6: 1=Editing area is the lower screen, 0=Editing area is the main screen.
                                            //    Bit 7: 1=Waiting for key press, 0=Got key press.
R0_EC0E: .space 1                           //  Mode:
                                            //    $00 = Edit Menu mode.
                                            //    $04 = Calculator mode.
                                            //    $07 = Tape Loader mode. [Effectively not used as overwritten by $FF]
                                            //    $FF = Tape Loader mode.
R0_EC0F: .space 1                           //  Main screen colours used by the 128 BASIC Editor - alternate ATTR_P.
R0_EC10: .space 1                           //  Main screen colours used by the 128 BASIC Editor - alternate MASK_P.
R0_EC11: .space 1                           //  Temporary screen colours used by the 128 BASIC Editor - alternate ATTR_T.
R0_EC12: .space 1                           //  Temporary screen colours used by the 128 BASIC Editor - alternate MASK_T.
R0_EC13: .space 1                           //  Temporary store for P_FLAG:
                                            //    Bit 0: 1=OVER 1, 0=OVER 0.
                                            //    Bit 1: Not used (always 0).
                                            //    Bit 2: 1=INVERSE 1, INVERSE 0.
                                            //    Bit 3: Not used (always 0).
                                            //    Bit 4: 1=Using INK 9.
                                            //    Bit 5: Not used (always 0).
                                            //    Bit 6: 1=Using PAPER 9.
                                            //    Bit 7: Not used (always 0).
R0_EC14: .space 1                           //  Not used.
R0_EC15: .space 1                           //  Holds the number of editing lines: 20 for the main screen, 1 for the lower screen.
R0_EC16: .space 735                         //  Screen Line Edit Buffer. This represents the text on screen that can be edited. It holds 21 rows,
                                            //  with each row consisting of 32 characters followed by 3 data bytes. Areas of white
                                            //  space that do not contain any editable characters (e.g. the indent that starts subsequent
                                            //  rows of a BASIC line) contain the value $00.
                                            //    Data Byte 0:
                                            //      Bit 0: 1=The first row of the BASIC line.
                                            //      Bit 1: 1=Spans onto next row.
                                            //      Bit 2: Not used (always 0).
                                            //      Bit 3: 1=The last row of the BASIC line.
                                            //      Bit 4: 1=Associated line number stored.
                                            //      Bit 5: Not used (always 0).
                                            //      Bit 6: Not used (always 0).
                                            //      Bit 7: Not used (always 0).
                                            //    Data Bytes 1-2: Line number of corresponding BASIC line (stored for the first row of the BASIC line only, holds $0000).
R0_EEF5: .space 1                           //  Flags used when listing the BASIC program:
                                            //    Bit 0   : 0=Not on the current line, 1=On the current line.
                                            //    Bit 1   : 0=Previously found the current line, 1=Not yet found the current line.
                                            //    Bit 2   : 0=Enable display file updates, 1=Disable display file updates.
                                            //    Bits 3-7: Not used (always 0).
R0_EEF6: .space 1                           //  Store for temporarily saving the value of TVFLAG.
R0_EEF7: .space 1                           //  Store for temporarily saving the value of COORDS.
R0_EEF9: .space 1                           //  Store for temporarily saving the value of P_POSN.
R0_EEFA: .space 2                           //  Store for temporarily saving the value of PR_CC.
R0_EEFC: .space 2                           //  Store for temporarily saving the value of ECHO_E.
R0_EEFE: .space 2                           //  Store for temporarily saving the value of DF_CC.
R0_EF00: .space 2                           //  Store for temporarily saving the value of DF_CCL.
R0_EF01: .space 1                           //  Store for temporarily saving the value of S_POSN.
R0_EF03: .space 2                           //  Store for temporarily saving the value of SPOSNL.
R0_EF05: .space 1                           //  Store for temporarily saving the value of SCR_CT.
R0_EF06: .space 1                           //  Store for temporarily saving the value of ATTR_P.
R0_EF07: .space 1                           //  Store for temporarily saving the value of MASK_P.
R0_EF08: .space 1                           //  Store for temporarily saving the value of ATTR_T.
R0_EF09: .space 1512                        //  Used to store screen area (12 rows of 14 columns) where menu will be shown.
                                            //  The rows are stored one after the other, with each row consisting of the following:
                                            //    - 8 lines of 14 display file bytes.
                                            //    - 14 attribute file bytes.
//  $F4F1-$F6E9        Not used. 505 bytes.
R0_F6EA: .space 2                           //  The jump table address for the current menu.
R0_F6EC: .space 2                           //  The text table address for the current menu.
R0_F6EE: .space 1                           //  Cursor position info - Current row number.
R0_F6EF: .space 1                           //  Cursor position info - Current column number.
R0_F6F0: .space 1                           //  Cursor position info - Preferred column number. Holds the last user selected column position. The Editor will attempt to
                                            //  place the cursor on this column when the user moves up or down to a new line.
R0_F6F1: .space 1                           //  Edit area info - Top row threshold for scrolling up.
R0_F6F2: .space 1                           //  Edit area info - Bottom row threshold for scrolling down.
R0_F6F3: .space 1                           //  Edit area info - Number of rows in the editing area.
R0_F6F4: .space 1                           //  Flags used when deleting:
                                            //    Bit 0   : 1=Deleting on last row of the BASIC line, 0=Deleting on row other than the last row of the BASIC line.
                                            //    Bits 1-7: Not used (always 0).
R0_F6F5: .space 1                           //  Number of rows held in the Below-Screen Line Edit Buffer.
R0_F6F6: .space 2                           //  Intended to point to the next location to access within the Below-Screen Line Edit Buffer, but incorrectly initialised to $0000 by the routine at $30D6 (ROM 0) and then never used.
R0_F6F8: .space 735                         //  Below-Screen Line Edit Buffer. Holds the remainder of a BASIC line that has overflowed off the bottom of the Screen Line Edit Buffer. It can hold 21 rows, with each row
                                            //  consisting of 32 characters followed by 3 data bytes. Areas of white space that do not contain any editable characters (e.g. the indent that starts subsequent rows of a BASIC line)
                                            //  contain the value $00.
                                            //    Data Byte 0:
                                            //      Bit 0: 1=The first row of the BASIC line.
                                            //      Bit 1: 1=Spans onto next row.
                                            //      Bit 2: Not used (always 0).
                                            //      Bit 3: 1=The last row of the BASIC line.
                                            //      Bit 4: 1=Associated line number stored.
                                            //      Bit 5: Not used (always 0).
                                            //      Bit 6: Not used (always 0).
                                            //      Bit 7: Not used (always 0).
                                            //    Data Bytes 1-2: Line number of corresponding BASIC line (stored for the first row of the BASIC line only, holds $0000).
R0_F9D7: .space 2                           //  Line number of the BASIC line in the program area being edited (or $0000 for no line).
R0_F9DB: .space 1                           //  Number of rows held in the Above-Screen Line Edit Buffer.
R0_F9DC: .space 2                           //  Points to the next location to access within the Above-Screen Line Edit Buffer.
R0_F9DE: .space 700                         //  Above-Screen Line Edit Buffer. Holds the rows of a BASIC line that has overflowed off the top of the Screen Line Edit Buffer.
                                            //  It can hold 20 rows, with each row consisting of 32 characters followed by 3 data bytes. Areas of white space that do not
                                            //  contain any editable characters (e.g. the indent that starts subsequent rows of a BASIC line) contain the value $00.
                                            //    Data Byte 0:
                                            //      Bit 0: 1=The first row of the BASIC line.
                                            //      Bit 1: 1=Spans onto next row.
                                            //      Bit 2: Not used (always 0).
                                            //      Bit 3: 1=The last row of the BASIC line.
                                            //      Bit 4: 1=Associated line number stored.
                                            //      Bit 5: Not used (always 0).
                                            //      Bit 6: Not used (always 0).
                                            //      Bit 7: Not used (always 0).
                                            //    Data Bytes 1-2: Line number of corresponding BASIC line (stored for the first row of the BASIC line only, holds $0000).
R0_FC9A: .space 2                           //  The line number at the top of the screen, or $0000 for the first line.
R0_FC9E: .space 1                           //  $00=Print a leading space when constructing keyword.
R0_FC9F: .space 2                           //  Address of the next character to fetch within the BASIC line in the program area, or $0000 for no next character.
R0_FCA1: .space 2                           //  Address of the next character to fetch from the Keyword Construction Buffer, or $0000 for no next character.
R0_FCA3: .space 11                          //  Keyword Construction Buffer. Holds either a line number or keyword string representation.
//  $FCAE-$FCFC        Construct a BASIC Line routine.
//  $FCFD-$FD2D        Copy String Into Keyword Construction Buffer routine.
//  $FD2E-$FD69        Identify Character Code of Token String routine.
R0_FD6A: .space 1                           //  Flags used when shifting BASIC lines within edit buffer rows [Redundant]:
                                            //    Bit 0  : 1=Set to 1 but never reset or tested. Possibly intended to indicate the start of a new BASIC line and hence whether indentation required.
                                            //    Bit 1-7: Not used (always 0).
R0_FD6B: .space 1                           //  The number of characters to indent subsequent rows of a BASIC line by.
R0_FD6C: .space 1                           //  Cursor settings (indexed by IX+$00) - initialised to $00, but never used.
R0_FD6D: .space 1                           //  Cursor settings (indexed by IX+$01) - number of rows above the editing area.
R0_FD6E: .space 1                           //  Cursor settings (indexed by IX+$02) - initialised to $00 (when using lower screen) or $14 (when using main screen), but never subsequently used.
R0_FD6F: .space 1                           //  Cursor settings (indexed by IX+$03) - initialised to $00, but never subsequently used.
R0_FD70: .space 1                           //  Cursor settings (indexed by IX+$04) - initialised to $00, but never subsequently used.
R0_FD71: .space 1                           //  Cursor settings (indexed by IX+$05) - initialised to $00, but never subsequently used.
R0_FD72: .space 1                           //  Cursor settings (indexed by IX+$06) - attribute colour.
R0_FD73: .space 1                           //  Cursor settings (indexed by IX+$07) - screen attribute where cursor is displayed.
R0_FD74: .space 9                           //  The Keyword Conversion Buffer holding text to examine to see if it is a keyword.
R0_FD7D: .space 2                           //  Address of next available location within the Keyword Conversion Buffer.
R0_FD7F: .space 2                           //  Address of the space character between words in the Keyword Conversion Buffer.
R0_FD81: .space 1                           //  Keyword Conversion Buffer flags, used when tokenizing a BASIC line:
                                            //    Bit 0   : 1=Buffer contains characters.
                                            //    Bit 1   : 1=Indicates within quotes.
                                            //    Bit 2   : 1=Indicates within a REM.
                                            //    Bits 3-7: Not used (always reset to 0).
R0_FD82: .space 2                           //  Address of the position to insert the next character within the BASIC line workspace. The BASIC line
                                            //  is created at the spare space pointed to by E_LINE.
R0_FD84: .space 1                           //  BASIC line insertion flags, used when inserting a characters into the BASIC line workspace:
                                            //    Bit 0   : 1=The last character was a token.
                                            //    Bit 1   : 1=The last character was a space.
                                            //    Bits 2-7: Not used (always 0).
R0_FD85: .space 2                           //  Count of the number of characters in the typed BASIC line being inserted.
R0_FD87: .space 2                           //  Count of the number of characters in the tokenized version of the BASIC line being inserted.
R0_FD89: .space 1                           //  Holds '<' or '>' if this was the previously examined character during tokenization of a BASIC line, else $00.
R0_FD8A: .space 1                           //  Locate Error Marker flag, holding $01 is a syntax error was detected on the BASIC line being inserted and the equivalent position within
                                            //  the typed BASIC line needs to be found with, else it holds $00 when tokenizing a BASIC line.
R0_FD8B: .space 2                           //  Stores the stack pointer for restoration upon an insertion error into the BASIC line workspace.
//  $FD8C-$FF23        Not used. 408 bytes.
//  R0_FF24: .space 2    Never used. An attempt is made to set it to $EC00. This is a remnant from the Spanish 128, which stored the address of the Screen Buffer here.
//                     The value is written to RAM bank 0 instead of RAM bank 7, and the value never subsequently accessed.
//  R0_FF26: .space 2    Not used.
//  $FF28-$FF60        Not used. On the Spanish 128 this memory holds a routine that copies a character into the display file. The code to copy to routine into RAM,
//                     and the routine itself are present in ROM 0 but are never executed.
//  $FF61-$FFFF        Not used. 159 bytes.

TVFLAG_TEMP:  .space  1

// TODO: When running in bare metal, we should increase this to e.g. 512MB (0x20000000)
HEAP: .space 0x80000                        // 512KB - for storing everything from CHANS to STKEND:
                                            //   Channel info
                                            //   BASIC Program
                                            //   Variables Area
                                            //   Edit Line
                                            //   Input Data
                                            //   Temp Workspace
                                            //   Calculator Stack
                                            //   etc...

// TODO: When running in bare metal, we should calcaulate available space in the linker script, rather than setting an explicit amount
.set RAMDISKSIZE, 0x80000                   // 512KB
RAMDISK: .space RAMDISKSIZE







.data
# ------------------------------------------------------------------------------
# System variables that are initialised to non-zero values
# ------------------------------------------------------------------------------



# ===========
# Menu Tables
# ===========

# ---------
# Main Menu
# ---------

# Jump table for the main 128K menu, referenced at 0x25AD (ROM 0).

R0_2744:  .byte 0x05                        // Number of entries.
        .byte 0x00
        .word R0_2831                       // Tape Loader option handler.
        .byte 0x01
        .word R0_286C                       // 128 BASIC option handler.
        .byte 0x02
        .word R0_2885                       // Calculator option handler.
        .byte 0x03
        .word R0_1B47                       // 48 BASIC option handler.
        .byte 0x04
        .word R0_2816                       // Tape Tester option handler.

# Text for the main 128K menu

R0_2754:  .byte 0x06                        // Number of entries.
        .ascii "128     "                   // Menu title.
        .byte 0xFF
R0_275E:  .ascii "Tape Loade"
        .byte 'r'+0x80
R0_2769:  .ascii "128 BASI"
        .byte 'C'+0x80
R0_2772:  .ascii "Calculato"
        .byte 'r'+0x80
        .ascii "48 BASI"
        .byte 'C'+0x80
R0_2784:  .ascii "Tape Teste"
        .byte 'r'+0x80

        .byte ' '+0x80                      // 0xA0. End marker.

# ---------
# Edit Menu
# ---------

# Jump table for the Edit menu

R0_2790:  .byte 0x05                        // Number of entries.
        .byte 0x00
        .word R0_2742                       // (Return to) 128 BASIC option handler.
        .byte 0x01
        .word R0_2851                       // Renumber option handler.
        .byte 0x02
        .word R0_2811                       // Screen option handler.
        .byte 0x03
        .word R0_2862                       // Print option handler.
        .byte 0x04
        .word R0_281C                       // Exit option handler.

# Text for the Edit menu

R0_27A0:  .byte 0x06                        // Number of entries.
        .ascii "Options "
        .byte 0xFF
        .ascii "128 BASI"
        .byte 'C'+0x80
        .ascii "Renumbe"
        .byte 'r'+0x80
        .ascii "Scree"
        .byte 'n'+0x80
        .ascii "Prin"
        .byte 't'+0x80
        .ascii "Exi"
        .byte 't'+0x80

        .byte ' '+0x80                      // 0xA0. End marker.

# ---------------
# Calculator Menu
# ---------------

# Jump table for the Calculator menu

R0_27CB:  .byte 0x02                        // Number of entries.
        .byte 0x00
        .word R0_2742                       // (Return to) Calculator option handler.
        .byte 0x01
        .word R0_281C                       // Exit option handler.

# Text for the Calculator menu

R0_27D2:  .byte 03                          // Number of entries.
        .ascii "Options "
        .byte 0xFF
        .ascii "Calculato"
        .byte 'r'+0x80
        .ascii "Exi"
        .byte 't'+0x80

        .byte ' '+0x80                      // 0xA0. End marker.

# ------------------------
# Menu Title Colours Table
# ------------------------

R0_37EC:  .byte 0x16, 0x07, 0x07            // AT 7,7;
        .byte 0x15, 0x00                    // OVER 0;
        .byte 0x14, 0x00                    // INVERSE 0;
        .byte 0x10, 0x07                    // INK 7;
        .byte 0x11, 00                      // PAPER 0;
        .byte 0x13, 0x01                    // BRIGHT 1;
        .byte 0xFF                          //

# ----------------------
# Menu Title Space Table
# ----------------------

R0_37FA:  .byte 0x11, 0x00                  // PAPER 0;
        .byte ' '                           //
        .byte 0x11, 0x07                    // PAPER 7;
        .byte 0x10, 0x00                    // INK 0;
        .byte 0xFF                          //

# -----------------------------
# Menu Sinclair Stripes Bitmaps
# -----------------------------
# Bit-patterns for the Sinclair stripes used on the menus.

R0_3802:  .byte 0x01                        // 0 0 0 0 0 0 0 1           X
        .byte 0x03                          // 0 0 0 0 0 0 1 1          XX
        .byte 0x07                          // 0 0 0 0 0 1 1 1         XXX
        .byte 0x0F                          // 0 0 0 0 1 1 1 1        XXXX
        .byte 0x1F                          // 0 0 0 1 1 1 1 1       XXXXX
        .byte 0x3F                          // 0 0 1 1 1 1 1 1      XXXXXX
        .byte 0x7F                          // 0 1 1 1 1 1 1 1     XXXXXXX
        .byte 0xFF                          // 1 1 1 1 1 1 1 1    XXXXXXXX

        .byte 0xFE                          // 1 1 1 1 1 1 1 0    XXXXXXX
        .byte 0xFC                          // 1 1 1 1 1 1 0 0    XXXXXX
        .byte 0xF8                          // 1 1 1 1 1 0 0 0    XXXXX
        .byte 0xF0                          // 1 1 1 1 0 0 0 0    XXXX
        .byte 0xE0                          // 1 1 1 0 0 0 0 0    XXX
        .byte 0xC0                          // 1 1 0 0 0 0 0 0    XX
        .byte 0x80                          // 1 0 0 0 0 0 0 0    X
        .byte 0x00                          // 0 0 0 0 0 0 0 0

# ---------------------
# Sinclair Strip 'Text'
# ---------------------
# CHARS points to RAM at 0x5A98, and characters ' ' and '!' redefined
# as the Sinclair strips using the bit patterns above.

R0_3812:  .byte 0x10, 0x02, ' '             // INK 2;
        .byte 0x11, 0x06, '!'               // PAPER 6;
        .byte 0x10, 0x04, ' '               // INK 4;
        .byte 0x11, 0x05, '!'               // PAPER 5;
        .byte 0x10, 0x00, ' '               // INK 0;
        .byte 0xFF

# ================================
# INITIALISATION ROUTINES - PART 3
# ================================

# ---------------------------------
# The 'Initial Channel Information'
# ---------------------------------
# Initially there are four channels ('K', 'S', 'R', & 'P') for communicating with the 'keyboard', 'screen', 'work space' and 'printer'.
# For each channel the output routine address comes before the input routine address and the channel's code.
# This table is almost identical to that in ROM 1 at 0x15AF but with changes to the channel P routines to use the RS232 port
# instead of the ZX Printer.
# Used at 0x01DD (ROM 0).

R0_0589:  .quad R1_09F4                     // PRINT_OUT - K channel output routine.
          .quad R1_10A8                     // KEY_INPUT - K channel input routine.
          .byte 'K'                         // 0x4B      - Channel identifier 'K'.
          .quad R1_09F4                     // PRINT_OUT - S channel output routine.
          .quad R1_15C4                     // REPORT_J  - S channel input routine.
          .byte 'S'                         // 0x53      - Channel identifier 'S'.
          .quad R1_0F81                     // ADD_CHAR  - R channel output routine.
          .quad R1_15C4                     // REPORT_J  - R channel input routine.
          .byte 'R'                         // 0x52      - Channel identifier 'R'.
          .quad R1_5B34                     // POUT      - P Channel output routine.
          .quad R1_5B2F                     // PIN       - P Channel input routine.
          .byte 'P'                         // 0x50      - Channel identifier 'P'.
          .byte 0x80                        // End marker.

# -------------------------
# The 'Initial Stream Data'
# -------------------------
# Initially there are seven streams - 0xFD to 0x03.
# This table is identical to that in ROM 1 at 0x15C6.
# Used at 0x0226 (ROM 0).

R0_059E:  .byte 0x01, 0x00                  // Stream 0xFD leads to channel 'K'.
          .byte 0x06, 0x00                  // Stream 0xFE leads to channel 'S'.
          .byte 0x0B, 0x00                  // Stream 0xFF leads to channel 'R'.
          .byte 0x01, 0x00                  // Stream 0x00 leads to channel 'K'.
          .byte 0x01, 0x00                  // Stream 0x01 leads to channel 'K'.
          .byte 0x06, 0x00                  // Stream 0x02 leads to channel 'S'.
          .byte 0x10, 0x00                  // Stream 0x03 leads to channel 'P'.

.text
# -----------
# Entry point
# -----------

_start:
  mrs     x0, mpidr_el1                   // x0 = Multiprocessor Affinity Register.
  and     x0, x0, #0x3                    // x0 = core number.
  cbnz    x0, sleep_core                  // Put all cores except core 0 to sleep.
  mov     sp, STACK                       // Set initial Stack Pointer address.
  mov     x29, 0                          // Frame pointer 0 indicates end of stack.
  adr     x28, sysvars                    // x28 will remain at this constant value to make all sys vars via an immediate offset.
# bl      uart_init                       // Initialise UART interface.
  bl      init_framebuffer                // Allocate a frame buffer with chosen screen settings.
  ldr     w0, [x28, bordercolour-sysvars] // w0 = default border colour from bordercolour sys variable.
  bl      paint_border                    // Paint the screen border with the given border colour.
  ldr     w0, [x28, papercolour-sysvars]  // w0 = default paper colour from papercolour sys variable.
  bl      paint_window                    // Paint the main window (everything except border)
  bl      paint_copyright                 // Paint the copyright text ((C) 1982 Amstrad....)
  b       sleep_core                      // Go to sleep; it has been a long day.


# When running on bare metal, should disable interrupts, set up stack, vector
# jump tables, switch execution level etc, and all the kinds of things to
# initialise the processor system registers, memory virtualisation, initialise
# UART, sound chip, USB, ... etc etc
#
# zero out memory?????
#
R0_0137:
  mov x0, RAMDISKSIZE                       // x0 = size of ramdisk.
  sub x0, x0, #0x60                         // x0 = offset from start of RAM disk to last journal entry; RAM disk entries are 96 (0x60) bytes and journal grows downwards from end of ramdisk.
  adr x1, RAMDISK                           // x1 = start address of ramdisk.
  add x2, x0, x1                            // x2 = absolute address of last journal entry of RAM disk.
  adr x28, SYSVARS                          // x28 = SYSVARS.
  str x2, [x28, SFNEXT-SYSVARS]             // Store current journal entry in SFNEXT.
  str x1, [x2, #0x40]                       // Store RAMDISK start location in first RAM Disk Catalogue journal entry.
  str x0, [x28, SFSPACE-SYSVARS]            // Store free space in SFSPACE.
  .set GPU_START, 0x500000
  # .set GPU_START, 0x3c000000              // First byte of shared GPU memory. Note, if we support other RPI models later, we'll need to set this based on the model. This also assumes 64MB gpu.
  mov x5, GPU_START                         // Pretend first byte of shared GPU memory, for determining where CPU dedicated RAM ends (one byte below).
  sub x5, x5, 1                             // Last byte of dedicated RAM (not shared with GPU).
  str x5, [x28, P_RAMT-SYSVARS]             // [P_RAMT] = 0x3bffffff on bare metal, but something much less as a userspace program.
  .set USER_GRAPHICS_COUNT, 0x15            // There are 21 User Graphics to copy.
  mov x6, USER_GRAPHICS_COUNT
  adr x7, R1_3D00 + (65 - 32) * 8           // Skip 33 chars to reach char 'A'.
  sub x9, x5, USER_GRAPHICS_COUNT * 8 - 1   // x9 = first byte of user graphics.
  str x9, [x28, UDG-SYSVARS]                // [UDG] = first byte of user graphics.

  # Copy USER_GRAPHICS_COUNT characters into User Defined Graphics memory region at end of RAM.
  1:
    ldr x8, [x7], 8
    str x8, [x9], 8
    subs x6, x6, 1
    b.ne 1b
  mov w12, 0x0040
  strh w12, [x28, RASP-SYSVARS]             // [RASP]=0x40 [PIP]=0x00 <-- need to check this works!!
  sub x13, x9, 1
  str x13, [x28, RAMTOP-SYSVARS]            // [RAMPTOP] = UDG - 1 (address of last byte before UDG starts).

# Entry point for NEW (with interrupts disabled when running in bare metal since this routine will enable interrupts)
R0_019D:
  adr x0, R1_3D00 - (0x08 * 0x20)           // x0 = where, in theory character zero would be.
  str x0, [x28, CHARS-SYSVARS]              // [CHARS] = theoretical address of char zero.
  ldr x1, [x28, RAMTOP-SYSVARS]             // x1 = [RAMTOP].
  add x1, x1, 1                             // x1 = [RAMTOP] + 1.
  and sp, x1, 0xfffffff0                    // sp = highest 16-byte aligned address equal to or lower than ([RAMTOP] + 1).
  ldrb w1, [x28, FLAGS-SYSVARS]             // w1 = [FLAGS].
  orr w1, w1, #0x10                         // w1 = [FLAGS] with bit 4 set.
                                            // [This bit is unused by 48K BASIC].
  strb w1, [x28, FLAGS-SYSVARS]             // Update [FLAGS] to have bit 4 set.
  # Here we should also set interuppt mode, and enable interrupts, and initialise printer / UART configuration
  mov w2, 0x000B                            // = 11; timing constant for 9600 baud. Maybe useful for UART?
  strh w2, [x28, BAUD-SYSVARS]              // [BAUD] = 0x000B
  strb wzr, [x28, SERFL-SYSVARS]            // 0x5B61. Indicate no byte waiting in RS232 receive buffer.
  strb wzr, [x28, COL-SYSVARS]              // 0x5B63. Set RS232 output column position to 0.
  strb wzr, [x28, TVPARS-SYSVARS]           // 0x5B65. Indicate no control code parameters expected.
  mov w3, 0x50                              // Default to a printer width of 80 columns.
  strb w3, [x28, WIDTH-SYSVARS]             // 0x5B64. Set RS232 printer output width.
  mov w4, 0x000A                            // Use 10 as the initial renumber line and increment.
  strh w4, [x28, RNFIRST-SYSVARS]           // Store the initial line number when renumbering.
  strh w4, [x28, RNSTEP-SYSVARS]            // Store the renumber line increment.
  adr x5, HEAP                              // x5 = start of heap
  str x5, [x28, CHANS-SYSVARS]              // [CHANS] = start of heap
  mov x6, (8+8+1)*4+1
  adr x7, R0_0589

  # Copy 69 bytes from R0_0589 to [CHANS] = start of heap = HEAP
  1:
    ldrb w8, [x7], 1
    strb w8, [x5], 1
    subs x6, x6, 1
    b.ne 1b

  sub x9, x5, 1
  str x9, [x28, DATADD-SYSVARS]
  str x5, [x28, PROG-SYSVARS]
  str x5, [x28, VARS-SYSVARS]
  mov w10, 0x80
  strb w10, [x5], 1
  str x5, [x28, E_LINE-SYSVARS]
  mov w11, 0x0D
  strb w11, [x5], 1
  strb w10, [x5], 1
  str x5, [x28, WORKSP-SYSVARS]
  str x5, [x28, STKBOT-SYSVARS]
  str x5, [x28, STKEND-SYSVARS]
  mov w12, 0x38
  strb w12, [x28, ATTR_P-SYSVARS]
  strb w12, [x28, MASK_P-SYSVARS]
  strb w12, [x28, BORDCR-SYSVARS]

  ldr     w0, [x28, bordercolour-sysvars]
  bl      paint_border

  mov w13, 0x0523                           // The values five and thirty five.
  strh w12, [x28, REPDEL-SYSVARS]           // REPDEL. Set the default values for key delay and key repeat.

#
#         DEC  (IY-0x3A)     // Set KSTATE+0 to 0xFF.
#         DEC  (IY-0x36)     // Set KSTATE+4 to 0xFF.
#



#         LD   HL,L059E     // Address of the Initial Stream Data within this ROM (which is identical to that in main ROM).
#         LD   DE,0x5C10     // STRMS. Address of the system variable holding the channels attached to streams data.
#         LD   BC,0x000E     //
#         LDIR              // Initialise the streams system variables.
#
#         RES  1,(IY+0x01)   // FLAGS. Signal printer not is use.
#         LD   (IY+0x00),0xFF // ERR_NR. Signal no error.
#         LD   (IY+0x31),0x02 // DF_SZ. Set the lower screen size to two rows.
#
#         RST  28H          //
#         .word CLS          // 0x0D6B. Clear the screen.
#         RST  28H          // Attempt to display TV tuning test screen.
#         .word TEST_SCREEN  // 0x3C04. Will return if BREAK is not being pressed.
#
#         LD   DE,L0561     // Address of the Sinclair copyright message.
#         CALL L057D        // Display the copyright message.
#
#         LD   (IY+0x31),0x02 // DF_SZ. Set the lower screen size to two rows.
#         SET  5,(IY+0x02)   // TV_FLAG. Signal lower screen will require clearing.
#
#         LD   HL,TSTACK    // 0x5BFF.
#         LD   (OLDSP),HL   // 0x5B81. Use the temporary stack as the previous stack.
#
#         CALL L1F45        // Use Workspace RAM configuration (physical RAM bank 7).
#
#         LD   A,0x38        // Set colours to black ink on white paper.
#         LD   (0xEC11),A    // Temporary ATTR_T used by the 128 BASIC Editor.
#         LD   (0xEC0F),A    // Temporary ATTR_P used by the 128 BASIC Editor.
#
#         XOR  A            // Clear the accumulator.
#         LD   (0xEC13),A    // Temporary P_FLAG. Temporary store for P-FLAG.
#
#         CALL L2584        // Initialise mode and cursor settings. IX will point at editing settings information.
#
#         CALL L1F20        // Use Normal RAM Configuration (physical RAM bank 0).
#         JP   L259F        // Jump to show the Main menu.




  adr x0, R0_2754                           // The Main Menu text.
  bl display_menu                           // Display menu (R0_36A8).
  mov x0, 123                               // Exit code.
  mov x8, 93                                // sys_exit() is at index 93 in kernel functions table.
  svc 0                                     // Generate kernel call sys_exit(123).


# R0_0010
print_byte:
  adr x1, CURCHL
  ldrb w2, [x1]

memcpy8x:
  # probably should have e.g. `prfm PLDL1KEEP ....` here
  # see http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0802b/PRFM_reg.html




# memcpy:
#   See https://stackoverflow.com/questions/49474381/using-aarch64-assembly-to-write-a-memcpy
#   and https://code.woboq.org/userspace/glibc/sysdeps/aarch64/memcpy.S.html


####
# ARM-recommended (for interoperability) register use, but not required
# since our kernel does not interoperate with third party code. However,
# might be worth conforming to, if it does no harm, as a matter of best
# practice.
#
# x0-7   For passing arguments into and out of functions. presumably, code
#        should not assume that the passed in values remain in the registers
#        when the call returns.
# x9-15  Scratch registers that any routine can trash, so only use for temp
#        computation that doesn't make any function calls.
# x19-28 Registers that should be pushed on the stack before calling a subroutine
# x29    Frame pointer
# x30    Link register (set by bl instructions)
#
# Adopting this convention to be compliant with ARM Procedure Call Standard,
# although isn't really important as this code doesn't interface with other
# libraries.

# ======================
# MENU ROUTINES - PART 5
# ======================

# ------------
# Display Menu
# ------------
# from R0_36A8

# x0=Address of menu text.
display_menu:
  stp x29, x30, [sp, #-0x10]!               // Push frame pointer, procedure link register on stack.
  mov x29, sp                               // Update frame pointer to new stack location.
  stp x0, xzr, [sp, #-0x10]!                // Push x0 on the stack, and 8 unused zeros to retain 16 byte stack pointer alignment.
  bl store_menu_screen_area                 // Backup current menu screen area (R0_373B).

  /////////////////////////////////////////////////////////////////////////////////////////
  // This commented out version would require Armv8.1 extensions, not available
  // on Cortex-A53, only on Cortex-A{55,65,65AE,75,76,76AE,77}:
  //   adr x1, TVFLAG                       // Get address of TVFLAG sys var in x1.
  //   mov w2, 1                            // Bit mask for bits to clear
  //   stclrb w2, [x1]                      // Clear bit 0 of [TVFLAG]
  // Alternative version for ARMv8.0-A; compatible with Cortex-A53:
  ldrb w2, [x28, TVFLAG-SYSVARS]      // Get value of TVFLAG sys var in w2.
  and w2, w2, #0xFE                   // Reset bit 0.
  strb w2, [x28, TVFLAG-SYSVARS]      // Update TVFLAG sys var
  /////////////////////////////////////////////////////////////////////////////////////////

  adr x0, R0_37EC                           // Set title colours (control characters).
  bl print_string                           // Print them (R0_3733).
  ldp x0, xzr, [sp], #0x10                  // Pop x0 off the stack.
  ldrb w3, [x0]                             // Fetch number of table entries in w3.
  add x0, x0, #0x01                         // Point to first entry.
  bl print_string                           // Print menu title pointed to by x0 (R0_3733).
  stp x0, xzr, [sp, #-0x10]!                // Push x0 on the stack, and 8 unused zeros to retain 16 byte stack pointer alignment.
  bl print_sinclair_stripes                 // Print Sinclair stripes (R0_3822).
  adr x0, R0_37FA                           // Black ' ' and PAPER 7 / INK 0.
  bl print_string                           // Print it.
  ldp x0, xzr, [sp], #0x10                  // Pop x0 off the stack = Address of first menu item text.




  ldp x29, x30, [sp], #0x10                 // Pop frame pointer, procedure link register off stack.
  ret

# ----------------------
# Store Menu Screen Area
# ----------------------
# Store copy of menu screen area and system variables.
# from R0_373B
store_menu_screen_area:
  adr x1, TVFLAG
  adr x2, TVFLAG_TEMP
  ldrb w3, [x1]
  strb w3, [x2]
  ret


# ------------
# Print String
# ------------
# Print characters pointed to by x0 until $FF found.
# from R0_3733

# on entry:
#   x0=address
# on return:
#   x0=address after $FF found.
#   x1=0xff

print_string:
  stp x29, x30, [sp, #-0x10]!               // Push frame pointer, procedure link register on stack.
  mov x29, sp                               // Update frame pointer to new stack location.
1:
  ldrb w1, [x0]
  add x0, x0, #0x01
  cmp w1, #0xff
  b.ne 2f
  ldp x29, x30, [sp], #0x10                 // Pop frame pointer, procedure link register off stack.
  ret
2:
  bl print_byte
  b 1b

R0_0010:
  nop
R0_2831:
  nop
R0_286C:
  nop
R0_2885:
  nop
R0_1B47:
  nop
R0_2816:
  nop
R0_2742:
  nop
R0_2851:
  nop
R0_2811:
  nop
R0_2862:
  nop
R0_281C:
  nop


# R0_3822
print_sinclair_stripes:
  nop

R1_09F4:
  nop
R1_0F81:
  nop
R1_10A8:
  nop
R1_15C4:
  nop
R1_5B2F:
  nop
R1_5B34:
  nop


.set SCREEN_WIDTH,     1920
.set SCREEN_HEIGHT,    1200
.set BORDER_LEFT,      96
.set BORDER_RIGHT,     96
.set BORDER_TOP,       128
.set BORDER_BOTTOM,    112

.set MAILBOX_BASE,     0x3f00b880
.set MAILBOX_REQ_ADDR, 0x0
.set MAILBOX_WRITE,    0x20
.set MAILBOX_STATUS,   0x118
.set MAILBOX_EMPTY,    30
.set MAILBOX_FULL,     31

.set STACK,            0x80000

# Load a 32-bit immediate using mov.
.macro movl Wn, imm
  movz    \Wn,  \imm & 0xFFFF
  movk    \Wn, (\imm >> 16) & 0xFFFF, lsl 16
.endm


init_framebuffer:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  movl     w9, MAILBOX_BASE               // x9 = 0x3f00b880 (Mailbox Peripheral Address)
  1:                                      // Wait for mailbox FULL flag to be clear.
    ldr     w10, [x9, MAILBOX_STATUS]     // w10 = mailbox status.
    tbnz    w10, MAILBOX_FULL, 1b         // If FULL flag set (bit 31), try again...
  adr     x10, mbreq                      // x10 = memory block pointer for mailbox call.
  mov     w11, 8                          // Mailbox channel 8.
  orr     w11, w10, w11                   // w11 = encoded request address + channel number.
  str     w11, [x9, MAILBOX_WRITE]        // Write request address / channel number to mailbox write register.
  2:                                      // Wait for mailbox EMPTY flag to be clear.
    ldr     w12, [x9, MAILBOX_STATUS]     // w12 = mailbox status.
    tbnz    w12, MAILBOX_EMPTY, 2b        // If EMPTY flag set (bit 30), try again...
  ldr     w12, [x9, MAILBOX_REQ_ADDR]     // w12 = message request address + channel number.
  cmp     w11, w12                        // See if the message is for us.
  b.ne    2b                              // If not, try again.
  ldr     w11, [x10, framebuffer-mbreq]   // w11 = allocated framebuffer address
  and     w11, w11, #0x3fffffff           // Clear upper bits beyond addressable memory
  str     w11, [x10, framebuffer-mbreq]   // Store framebuffer address in framebuffer system variable.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# Inputs:
#   w0 = colour to paint border
paint_border:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Push x19, x20 on the stack so x19 can be used in this function.
  mov     w19, w0                         // w19 = w0 (colour to paint border)
  mov     w0, 0                           // Paint rectangle from 0,0 (top left of screen) with width
  mov     w1, 0                           // SCREEN_WIDTH and height BORDER_TOP in colour w19 (border colour).
  mov     w2, SCREEN_WIDTH                // This is the border across the top of the screen.
  mov     w3, BORDER_TOP
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint left border in border colour. This starts below the top
  mov     w1, BORDER_TOP                  // border (0, BORDER_TOP) and is BORDER_LEFT wide and stops above
  mov     w2, BORDER_LEFT                 // the bottom border (drawn later in function).
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, SCREEN_WIDTH-BORDER_RIGHT   // Paint the right border in border colour. This also starts below
  mov     w1, BORDER_TOP                  // the top border, but on the right of the screen, and is
  mov     w2, BORDER_RIGHT                // BORDER_RIGHT wide. It also stops immediately above bottom border.
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint the bottom border in border colour. This is BORDER_BOTTOM
  mov     w1, SCREEN_HEIGHT-BORDER_BOTTOM // high, and is as wide as the screen.
  mov     w2, SCREEN_WIDTH
  mov     w3, BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  ldp     x19, x20, [sp], #0x10           // Restore x19 so no calling function is affected.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# Inputs:
#   w0 = x
#   w1 = y
#   w2 = width (pixels)
#   w3 = height (pixels)
#   w4 = colour
paint_rectangle:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w11, [x9, pitch-mbreq]          // w11 = pitch
  umaddl  x10, w1, w11, x10               // x10 = address of framebuffer + y*pitch
  add     w10, w10, w0, LSL #2            // w10 = address of framebuffer + y*pitch + x*4
  fill_rectangle:                         // Fills entire rectangle
    mov     w12, w10                      // w12 = reference to start of line
    mov     w13, w2                       // w13 = width of line
    fill_line:                            // Fill a single row of the rectangle with colour.
      str     w4, [x10], 4                // Colour current point, and update x10 to next point.
      sub     w13, w13, 1                 // Decrease horizontal pixel counter.
      cbnz    w13, fill_line              // Repeat until line complete.
    add     w10, w12, w11                 // x10 = start of current line + pitch = start of new line.
    sub     w3, w3, 1                     // Decrease vertical pixel counter.
    cbnz    w3, fill_rectangle            // Repeat until all framebuffer lines complete.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# Inputs:
#   w0 = colour to paint border
paint_window:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     w4, w0                          // Paint a single rectange that fills the gap inside the
  mov     w0, BORDER_LEFT                 // four borders of the screen.
  mov     w1, BORDER_TOP
  mov     w2, SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  bl      paint_rectangle
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# paint_string paints the zero byte delimited text string pointed to by x0 to the screen in the
# system font (16x16 pixels) at the screen print coordinates given by w1, w2. The ink colour is
# taken from w3 and paper colour from w4.
#
# Inputs:
#   x0 = pointer to string
#   w1 = x
#   w2 = y
#   w3 = ink colour
#   w4 = paper colour
paint_string:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w9, [x9, pitch-mbreq]           // w9 = pitch
  adr     x11, chars-32*32                // x11 = theoretical start of character table for char 0
1:
  ldrb    w12, [x0], 1                    // w12 = char from string, and update x0 to next char
  cbz     w12, 2f                         // if found end marker, jump to end of function and return
  add     x13, x11, x12, LSL #5           // x13 = address of character bitmap
  mov     w14, BORDER_TOP                 // w14 = BORDER_TOP
  add     w14, w14, w2, LSL #4            // w14 = BORDER_TOP + y * 16
  mov     w15, BORDER_LEFT                // w15 = BORDER_LEFT
  add     w15, w15, w1, LSL #4            // w15 = BORDER_LEFT + x * 16
  add     w15, w10, w15, LSL #2           // w15 = address of framebuffer + 4* (BORDER_LEFT + x * 16)
  umaddl  x14, w9, w14, x15               // w14 = pitch*(BORDER_TOP + y * 16) + address of framebuffer + 4 * (BORDER_LEFT + x*16)
  mov     w15, 16                         // w15 = y counter
  paint_char:
    mov     w16, w14                      // w16 = leftmost pixel of current row address
    mov     w12, 1 << 15                  // w12 = mask for current pixel
    ldrh    w17, [x13], 2                 // w17 = bitmap for current row, and update x13 to next bitmap pattern
    paint_line:                           // Paint a horizontal row of pixels of character
      tst     w17, w12                    // apply pixel mask
      csel    w18, w3, w4, ne             // if pixel set, colour w3 (ink colour) else colour w4 (paper colour)
      str     w18, [x14], 4               // Colour current point, and update x14 to next point.
      lsr     w12, w12, 1                 // Shift bit mask to next pixel
      cbnz    w12, paint_line             // Repeat until line complete.
    add     w14, w16, w9                  // x14 = start of current line + pitch = start of new line.
    sub     w15, w15, 1                   // Decrease vertical pixel counter.
    cbnz    w15, paint_char               // Repeat until all framebuffer lines complete.
  add     w1, w1, 1                       // Increment w1 (x print position) so that the next char starts to the right of the current char.
  b       1b                              // Repeat outer loop.
2:
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

paint_copyright:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_copyright               // x0 = location of system copyright message.
  mov     w1, 38                          // Print at x=38.
  mov     w2, 40                          // Print at y=40.
  ldr     w3, [x28, inkcolour-sysvars]    // Ink colour is default system ink colour.
  ldr     w4, [x28, papercolour-sysvars]  // Paper colour is default system paper colour.
  bl      paint_string                    // Paint the copyright string to screen.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


sleep_core:
  wfe                                     // Sleep until woken.
  b       sleep_core                      // Go back to sleep.

# Memory block for mailbox call
.align 4
mbreq:
  .word 140                               // Buffer size
  .word 0                                 // Request/response code
  .word 0x48003                           // Tag 0 - Set Screen Size
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                      //   request: width                response: width
  .word SCREEN_HEIGHT                     //   request: height               response: height
  .word 0x48004                           // Tag 1 - Set Virtual Screen Size
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                      //   request: width                response: width
  .word SCREEN_HEIGHT                     //   request: height               response: height
  .word 0x48009                           // Tag 2 - Set Virtual Offset
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 //   request: x offset             response: x offset
  .word 0                                 //   request: y offset             response: y offset
  .word 0x48005                           // Tag 3 - Set Colour Depth
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
                                          //                   32 bits per pixel => 8 red, 8 green, 8 blue, 8 alpha
                                          //                   See https://en.wikipedia.org/wiki/RGBA_color_space
  .word 32                                //   request: bits per pixel       response: bits per pixel
  .word 0x48006                           // Tag 4 - Set Pixel Order (really is "Colour Order", not "Pixel Order")
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 //   request: 0 => BGR, 1 => RGB   response: 0 => BGR, 1 => RGB
  .word 0x40001                           // Tag 5 - Get (Allocate) Buffer
  .word 8                                 //   value buffer size (response > request, so use response size)
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
framebuffer:
  .word 4096                              //   request: alignment in bytes   response: frame buffer base address
  .word 0                                 //   request: padding              response: frame buffer size in bytes
  .word 0x40008                           // Tag 6 - Get Pitch (bytes per line)
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
pitch:
  .word 0                                 //   request: padding              response: bytes per line
  .word 0                                 // End Tags

sysvars:
  bordercolour: .word 0x00cf0000          // Default border colour around screen.
  papercolour:  .word 0x00cfcfcf          // Default paper colour (background colour of screen)
  inkcolour:    .word 0x00000000          // Default ink colour (foreground colour of text on screen)

msg_copyright:
  .asciz "1982, 1986, 1987 Amstrad Plc."

.align 2
