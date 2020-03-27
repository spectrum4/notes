package lib

import (
	"image"
	"image/color"
)

func Render(display [213840]byte, img *image.NRGBA) {
	for i := uint(0); i < 207360; i++ {
		y := 128 + 16*((i/216)%20) + (i/(216*20))%16 + 320*(i/(216*20*16))
		p := display[i]
		attr := display[207360+((i/2)%108)+108*(((i/216)%20)+20*(i/(216*20*16)))]
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
	}
}
