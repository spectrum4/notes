package main

import (
	"fmt"
	"os"
	"github.com/davidminor/uint128"
)

func main() {
	failures := 0
	for a := uint16(0); a < 928; a++ {
		if usingNormalMaths(a) != usingUint128(a) {
			fmt.Printf("Failed on %v/320: got %v but should have %v\n", a, usingUint128(a), usingNormalMaths(a))
			failures++
		}
	}
	if failures > 1 {
		fmt.Printf("%v failures! See above.\n", failures)
	} else if failures == 0 {
		fmt.Println("All ok!")
		os.Exit(0)
	}
	os.Exit(64)
}

func usingUint128(in uint16) uint16 {
	c := uint128.Uint128 {
		L: 0xcd00000000000000,
	}
	d := uint128.Uint128 {
		L: uint64(in),
	}
	e := c.Mult(d)
	f := e.ShiftRight(72)
    return uint16(f.L)
}

func usingNormalMaths(in uint16) uint16 {
	return in/320
}
