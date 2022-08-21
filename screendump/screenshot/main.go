package main

import (
	"image"
	"image/color"
	"image/png"
	"io/ioutil"
	"log"
	"os"
)

func main() {
	data := load("input")
	// 207360
	// 6480
	display := [213840]byte{}
	copy(display[:], data)
	img := Render(display)
	create("image.png", img)
}

func create(filename string, im image.Image) {
	f, err := os.Create(filename)
	if err != nil {
		log.Fatal(err)
	}

	if err := png.Encode(f, im); err != nil {
		f.Close()
		log.Fatal(err)
	}

	if err := f.Close(); err != nil {
		log.Fatal(err)
	}
}

func load(filename string) []byte {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("Error reading file %v: %v", filename, err)
	}
	return data
}

func Render(display [213840]byte) image.Image {

	white := color.RGBA{0xcc, 0xcc, 0xcc, 0xff}
	palette := []color.Color{
		color.RGBA{0x00, 0x00, 0x00, 0xff}, color.RGBA{0x00, 0x00, 0xcc, 0xff},
		color.RGBA{0x00, 0xcc, 0x00, 0xff}, color.RGBA{0x00, 0xcc, 0xcc, 0xff},
		color.RGBA{0xcc, 0x00, 0x00, 0xff}, color.RGBA{0xcc, 0x00, 0xcc, 0xff},
		color.RGBA{0xcc, 0xcc, 0x00, 0xff}, color.RGBA{0xcc, 0xcc, 0xcc, 0xff},
		color.RGBA{0x00, 0x00, 0x00, 0xff}, color.RGBA{0x00, 0x00, 0xff, 0xff},
		color.RGBA{0x00, 0xff, 0x00, 0xff}, color.RGBA{0x00, 0xff, 0xff, 0xff},
		color.RGBA{0xff, 0x00, 0x00, 0xff}, color.RGBA{0xff, 0x00, 0xff, 0xff},
		color.RGBA{0xff, 0xff, 0x00, 0xff}, color.RGBA{0xff, 0xff, 0xff, 0xff},
	}
	img := image.NewPaletted(image.Rect(0, 0, 1920, 1200), palette)

	for x := 0; x < 96; x++ {
		for y := 0; y < 1200; y++ {
			img.Set(x, y, white)
		}
	}
	for x := 1824; x < 1920; x++ {
		for y := 0; y < 1200; y++ {
			img.Set(x, y, white)
		}
	}
	for x := 0; x < 1920; x++ {
		for y := 0; y < 128; y++ {
			img.Set(x, y, white)
		}
	}
	for x := 0; x < 1920; x++ {
		for y := 1088; y < 1200; y++ {
			img.Set(x, y, white)
		}
	}

	for i := uint(0); i < 213840; i++ {
		if i < 207360 {
			y := 128 + 16*((i/216)%20) + (i/(216*20))%16 + 320*(i/(216*20*16))
			p := display[i]
			// attr := display[207360+((i/2)%108)+108*(((i/216)%20)+20*(i/(216*20*16)))]
			var attr uint8 = 0x38
			for a := uint(0); a < 8; a++ {
				x := 96 + 8*(i%216) + a
				c := (p >> (7 - a)) & 0x01
				l := ((attr>>6)&0x01)*0x33 + 0xcc
				q := color.NRGBA{
					R: l * ((attr >> (4 - c*3)) & 0x1),
					G: l * ((attr >> (5 - c*3)) & 0x1),
					B: l * ((attr >> (3 - c*3)) & 0x1),
					A: 0xff,
				}
				img.Set(int(x), int(y), q)
			}
		} else {
			attr := display[i]
			x := int(16*((i-207360)%108) + 96)
			y := int(16*((i-207360)/108) + 128)
			for j := 0; j < 16; j++ {
				for k := 0; k < 16; k++ {
					r, g, b, _ := img.At(x+j, y+k).RGBA()
					c := uint(0)
					if r+g+b == 0 {
						c = 1
					} else {
						c = 0
					}
					l := ((attr>>6)&0x01)*0x33 + 0xcc
					q := color.NRGBA{
						R: l * ((attr >> (4 - c*3)) & 0x1),
						G: l * ((attr >> (5 - c*3)) & 0x1),
						B: l * ((attr >> (3 - c*3)) & 0x1),
						A: 0xff,
					}
					img.Set(int(x+j), int(y+k), q)
				}
			}
		}
	}
	return img
}
