package main

import (
	"image"
	"image/color"
	"image/gif"
	"image/png"
	"log"
	"os"
)

func main() {
	screen := image.NewNRGBA(image.Rectangle{
		// Min: image.ZP,
		Max: image.Point{
			X: 1920,
			Y: 1200,
		},
	})
	zxfile, err := os.Open("../spectrum_+2A_menu.gif")
	if err != nil {
		log.Fatalf("%v", err)
	}
	defer zxfile.Close()
	speccyscreen, err := gif.Decode(zxfile)
	if err != nil {
		log.Fatalf("%v", err)
	}
	// grey out entire screen
	for x := 0; x < 1920; x++ {
		for y := 0; y < 1200; y++ {
			if x < 96 || x >= 1920-96 || y < 128 || y >= 1200-112 {
				screen.Set(x, y, color.NRGBA{
					R: 0xcf,
					G: 0x00,
					B: 0x00,
					A: 0xff,
				})
			} else {
				screen.Set(x, y, color.NRGBA{
					R: 0xcf,
					G: 0xcf,
					B: 0xcf,
					A: 0xff,
				})
			}
		}
	}
	// Scale up original screen (make twice as wide and twice as tall
	// and centre it in the new screen. Avoid the dark borders around
	// screen that appear in the original gif (left, right, bottom).
	for x := 1 * 2; x < 321*2; x++ {
		for y := 0; y < 240*2; y++ {
			screen.Set(x-2+(1920-320*2)/2, y+(1200-240*2)/2, speccyscreen.At(x>>1, y>>1))
		}
	}
	var file *os.File
	file, err = os.Create("screen.png")
	if err != nil {
		log.Fatalf("%v", err)
	}
	defer file.Close()
	err = png.Encode(file, screen)
	if err != nil {
		log.Fatalf("%v", err)
	}

	// Dump raw data to logs
	// for x := 0; x < 1920; x++ {
	// 		for y := 0; y < 1200; y++ {
	// 			r, g, b, a := screen.At(x, y).RGBA()
	// 			fmt.Printf("0x%02x%02x%02x%02x\n", r>>8, g>>8, b>>8, a>>8)
	// 		}
	// 	}
}
