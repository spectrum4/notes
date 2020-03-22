package main

import (
	"fmt"
	"image/png"
	"log"
	"os"
	"strings"
)

const (
	borderWidth       = 4
	borderHeight      = 4
	charWidth         = 16
	charHeight        = 16
	columns           = 12
	rows              = 8
	chars             = 96
	leadingBlankChars = 0
	cutoff            = 100000
)

func main() {
	pngFile, err := os.Open("petefont.png")
	if err != nil {
		log.Fatalf("Whoops: %v", err)
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {
			log.Fatalf("Whoops: %v", err)
		}
	}(pngFile)
	img, err := png.Decode(pngFile)
	if err != nil {
		log.Fatalf("Whoops: %v", err)
	}

	fmt.Println(`.data


# -------------------------------
# THE 'ZX SPECTRUM CHARACTER SET'
# -------------------------------

.align 5
R1_3D00:
chars:`)

	for c := 0; c < chars; c++ {
		x := (c + leadingBlankChars) % columns
		y := (c + leadingBlankChars) / columns
		fmt.Println("")
		char := string(rune(c + 32))
		if c == 95 {
			char = "(c)"
		}
		fmt.Printf("# 0x%02X - Character: '%v' %v CHR$(%v)\n\n", c+32, char, strings.Repeat(" ", 9-len(char)), c+32)
		for j := y*(charHeight+borderHeight) + borderHeight; j < (y+1)*(charHeight+borderHeight); j++ {
			fmt.Print(`        .hword    0b`)

			for i := x*(charWidth+borderWidth) + borderWidth; i < (x+1)*(charWidth+borderWidth); i++ {
				r, g, b, a := img.At(i, j).RGBA()
				if r+g+b+a < cutoff {
					fmt.Print("1")
				} else {
					fmt.Print("0")
				}
				// fmt.Printf("x: %v, y: %v, total: %v\n", i, j, r+g+b+a)
			}
			fmt.Println("")
		}
	}
}
