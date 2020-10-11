package main

import (
	"log"
	"math/big"
	"os"
)

// This program compares that the instructions in po_attr routine of rom1.s
// produce the intended results, by performing the calculation in go, and
// comparing this to the calculation resulting from the assembly instructions,
// for every possible address offset in the display file.

func main() {

	_2_to_64 := big.NewInt(1 << 32)
	_2_to_64.Mul(_2_to_64, _2_to_64)

	// throw away variable
	temp := big.NewInt(0)

	x10 := big.NewInt(0)
	x11 := big.NewInt(0)
	x12 := big.NewInt(0)
	x13 := big.NewInt(0)
	x14 := big.NewInt(0)
	x15 := big.NewInt(0)
	x16 := big.NewInt(0)
	x17 := big.NewInt(0)
	x18 := big.NewInt(0)

	/*
	   # -------------
	   # Set attribute
	   # -------------
	   # Update the attribute entry in the attributes file for a corresponding display
	   # file address, based on attribute characteristics stored in system variables
	   # ATTR_T, MASK_T, P_FLAG.
	   #
	   # On entry:
	   #   x0 = address in display file
	   po_attr:                         // L0BDB
	     adr     x9, display_file                // x9 = start display file address
	     adr     x24, attributes_file            // x24 = start attributes file address
	     sub     x11, x0, x9                     // x11 = display file offset
	     // attribute address = attributes_file + ((x11/2) % 108) + 108 * (((x11/216) % 20) + 20 * (x11/(216*20*16)))
	     mov     x13, #0x0000684c00000000
	     movk    x13, #0x012f, lsl #48           // x13 = 0x012f684c00000000 = 85401593570131968
	     umulh   x14, x13, x11                   // x14 = (85401593570131968 * x11) / 18446744073709551616 = int(x11/216)
	     mov     x15, #0xcccd000000000000        // x15 = 14757451553962983424
	     umulh   x16, x15, x14                   // x16 = 14757451553962983424 * int(x11/216) / 2^64 = (4/5) * int(x11/216)
	     lsr     x16, x16, #4                    // x16 = int(int(x11/216)/20)
	     add     x16, x16, x16, lsl #2           // x16 = 5 * int(int(x11/216)/20)
	     sub     x16, x14, x16, lsl #2           // x16 = int(x11/216) - 20 * int(int(x11/216)/20) = (x11/216)%20
	     mov     x17, #0x0000f2ba00000000        // x17 = 266880677838848
	     umulh   x18, x17, x11                   // x18 = 266880677838848 * x11 / 2^64 = int(x11/(216*20*16))
	     add     x18, x18, x18, lsl #2           // x18 = 5*int(x11/(216*20*16))
	     mov     x12, #0x6c                      // x12 = 108
	     lsr     x10, x11, #1                    // x10 = int(x11/2)
	     msub    x10, x12, x14, x10              // x10 = int(x11/2)-108*int((x11/2)/108)=(x11/2)%108
	     add     x16, x16, x18, lsl #2           // x16 = (x11/216)%20+20*int(x11/(216*20*16))
	     madd    x16, x16, x12, x10              // x16 = 108*(((x11/216)%20+20*int(x11/(216*20*16))) + (x11/2)%108
	                                             //     = attribute address offset from attributes_file (x24)
	     ldrb    w17, [x24, x16]                 // w17 = attribute data
	*/

	for a := uint64(0); a < 216*20*16*3; a++ {

		x11.SetUint64(a)
		compare_assembly_vs_go("x11", x11, a)

		x13.SetUint64(0x012f684c00000000)
		compare_assembly_vs_go("x13", x13, 0x012f684c00000000)

		x14.Mul(x11, x13)
		x14.Div(x14, _2_to_64)
		compare_assembly_vs_go("x14", x14, a/216)

		x15.SetUint64(0xcccd000000000000)
		compare_assembly_vs_go("x15", x15, 0xcccd000000000000)

		x16.Mul(x14, x15)
		x16.Div(x16, _2_to_64)
		compare_assembly_vs_go("x16", x16, (4*(a/216))/5)

		x16.Div(x16, big.NewInt(1<<4))
		compare_assembly_vs_go("x16", x16, (a/216)/20)

		x16.Add(temp.Mul(x16, big.NewInt(1<<2)), x16)
		compare_assembly_vs_go("x16", x16, 5*((a/216)/20))

		x16.Sub(x14, temp.Mul(x16, big.NewInt(1<<2)))
		compare_assembly_vs_go("x16", x16, (a/216)%20)

		x17.SetUint64(0x0000f2ba00000000)
		compare_assembly_vs_go("x17", x17, 0x0000f2ba00000000)

		x18.Mul(x17, x11)
		x18.Div(x18, _2_to_64)
		compare_assembly_vs_go("x18", x18, a/(216*20*16))

		x18.Add(x18, temp.Mul(x18, big.NewInt(1<<2)))
		compare_assembly_vs_go("x18", x18, 5*(a/(216*20*16)))

		x12.SetUint64(108)
		compare_assembly_vs_go("x12", x12, 108)

		x10.Div(x11, big.NewInt(1<<1))
		compare_assembly_vs_go("x10", x10, a/2)

		x10.Sub(x10, temp.Mul(x12, x14))
		compare_assembly_vs_go("x10", x10, (a/2)%108)

		x16.Add(x16, temp.Mul(x18, big.NewInt(1<<2)))
		compare_assembly_vs_go("x16", x16, (a/216)%20+20*(a/(216*20*16)))

		x16.Add(x10, temp.Mul(x16, x12))
		compare_assembly_vs_go("x16", x16, ((a/2)%108)+108*(((a/216)%20)+20*(a/(216*20*16))))
	}
	log.Print("All ok!")
}

func compare_assembly_vs_go(register string, assemblyValue *big.Int, goValue uint64) {
	assemblyUint64 := assemblyValue.Uint64()
	log.Printf("%v: %20v / %v", register, assemblyUint64, goValue)
	if assemblyUint64 != goValue {
		log.Print("Failure!")
		os.Exit(1)
	}
}
