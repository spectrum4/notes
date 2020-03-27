package main

import (
	"fmt"
	"image"
	"image/color"
	"image/png"
	"io/ioutil"
	"log"
	"os"

	"github.com/petemoore/homescreen/screendump/lib"
)

func main() {
	// 207360
	// 6480
	display := [213840]byte{}
	origScreens := [][]byte{
		load("CJsElephantAntics.scr"),
		load("CrystalCastles.scr"),
		load("LordsOfChaos.scr"),
		load("LaserSquadEditor.scr"),
		load("Spellbound(Mastertronic).scr"),
		load("StreetFighter.scr"),
	}
	img := image.NewNRGBA(image.Rect(0, 0, 1920, 1200))
	for x := 0; x < 207360; x++ {
		display[x] = 0x0
	}
	for x := 207360; x < 213840; x++ {
		display[x] = 0x38
	}

	for i := uint(0); i < 3; i++ {
		for j := uint(0); j < 2; j++ {
			src := origScreens[j*3+i]
			for x := uint(0); x < 32; x++ {
				for y := uint(0); y < 192; y++ {
					p := src[(y&0xc0)<<5|(y&0x38)<<2|(y&0x07)<<8|x]
					for a := uint(0); a < 8; a++ {
						c := (p >> (7 - a)) & 0x01
						if c == 1 {
							newX := 48 + x*16 + i*(512+48) + a*2
							newY := 64 + y*2 + j*(384+64)
							offset := 216*(((newY%320)>>4)+20*(((newY%320)&0xf)+16*(newY/320))) + newX/8
							display[offset] |= 3 << (2 * (3 - a%4))
							display[offset+216*20] |= 3 << (2 * (3 - a%4))
						}
					}
				}
				for z := uint(0); z < 24; z++ {
					attr := src[6144+x+z*32]
					display[207360+x+i*35+3+108*(z+j*28+4)] = attr
				}
			}
		}
	}

	red := color.NRGBA{
		R: 0xcc,
		G: 0,
		B: 0,
		A: 0xff,
	}
	for x := 0; x < 96; x++ {
		for y := 0; y < 1200; y++ {
			img.Set(x, y, red)
		}
	}
	for x := 1824; x < 1920; x++ {
		for y := 0; y < 1200; y++ {
			img.Set(x, y, red)
		}
	}
	for x := 0; x < 1920; x++ {
		for y := 0; y < 128; y++ {
			img.Set(x, y, red)
		}
	}
	for x := 0; x < 1920; x++ {
		for y := 1088; y < 1200; y++ {
			img.Set(x, y, red)
		}
	}

	lib.Render(display, img)

	f, err := os.Create("image.png")
	if err != nil {
		log.Fatal(err)
	}

	if err := png.Encode(f, img); err != nil {
		f.Close()
		log.Fatal(err)
	}

	if err := f.Close(); err != nil {
		log.Fatal(err)
	}

	g, err := os.Create("../screen.s")
	if err != nil {
		log.Fatal(err)
	}
	defer g.Close()

	fmt.Fprintln(g, ".text")
	fmt.Fprintln(g, ".align 3")
	fmt.Fprintln(g, "")
	fmt.Fprintln(g, "ZX_SCREEN:")
	for i := 0; i < 213840; i += 8 {
		fmt.Fprint(g, ".quad 0x")
		for j := 0; j < 8; j++ {
			fmt.Fprintf(g, "%02x", display[i+(7-j)])
		}
		fmt.Fprintln(g, "")
	}
}

func load(filename string) []byte {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("Error reading file %v: %v", filename, err)
	}
	return data
}
