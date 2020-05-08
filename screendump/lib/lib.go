package lib

import (
	"image"
	"image/color"
	"image/gif"
	"log"
	"os"
)

func Render(display [213840]byte) image.Image {

	var images []*image.Paletted
	var delays []int
	for m := uint(0); m < 213840; m += 1234 {
		img := RenderPart(display, m)
		images = append(images, img.(*image.Paletted))
		delays = append(delays, 0)
	}
	img := RenderPart(display, uint(len(display)))
	images = append(images, img.(*image.Paletted))
	delays = append(delays, 1000)

	f, err := os.OpenFile("animated.gif", os.O_WRONLY|os.O_CREATE, 0600)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	gif.EncodeAll(f, &gif.GIF{
		Image: images,
		Delay: delays,
	})
	return img
}

func Shrink(img image.Image) image.Image {
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
	small := image.NewPaletted(image.Rect(0, 0, 1920/2, 1200/2), palette)
	for i := 0; i < 1920/2; i++ {
		for j := 0; j < 1200/2; j++ {
			small.Set(i, j, img.At(i*2, j*2))
		}
	}
	return small
}

func RenderPart(display [213840]byte, length uint) image.Image {

	red := color.NRGBA{
		R: 0xcc,
		G: 0,
		B: 0,
		A: 0xff,
	}
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

	for x := 96; x < 1824; x++ {
		for y := 128; y < 1088; y++ {
			img.Set(x, y, white)
		}
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
	for i := uint(0); i < length; i++ {
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
