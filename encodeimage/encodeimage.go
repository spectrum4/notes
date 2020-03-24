package main

import (
	"fmt"
	"image/png"
	"log"
	"os"
)

// This program generates a homer.h file from an arbitrary png file, passed as
// an argument to the program.  See:
// https://github.com/bztsrc/raspi3-tutorial/blob/7ace64ba9ff98011d37c74bba20890ccbd663ccb/09_framebuffer/homer.h
func main() {
	if len(os.Args) != 2 {
		log.Fatalf("Usage: %v <PNG-FILE>", os.Args[0])
	}
	pngfile, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatalf("%v", err)
	}
	defer pngfile.Close()
	pic, err := png.Decode(pngfile)
	if err != nil {
		log.Fatalf("%v", err)
	}
	bounds := pic.Bounds()
	width := bounds.Max.X - bounds.Min.X
	height := bounds.Max.Y - bounds.Min.Y

	fmt.Println(`/*  GIMP header image file format (RGB)  */`)
	fmt.Println(``)
	fmt.Printf("static unsigned int homer_width = %v;\n", width)
	fmt.Printf("static unsigned int homer_height = %v;\n", height)
	fmt.Println(``)
	fmt.Println(`/*  Call this macro repeatedly.  After each use, the pixel data can be extracted  */`)
	fmt.Println(``)
	fmt.Println(`#define HEADER_PIXEL(data,pixel) {\`)
	fmt.Println(`pixel[0] = (((data[0] - 33) << 2) | ((data[1] - 33) >> 4)); \`)
	fmt.Println(`pixel[1] = ((((data[1] - 33) & 0xF) << 4) | ((data[2] - 33) >> 2)); \`)
	fmt.Println(`pixel[2] = ((((data[2] - 33) & 0x3) << 6) | ((data[3] - 33))); \`)
	fmt.Println(`data += 4; \`)
	fmt.Println(`}`)
	fmt.Println(`static char *homer_data =`)

	var all string
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			r, g, b, _ := pic.At(x, y).RGBA()
			r >>= 8
			g >>= 8
			b >>= 8
			A := r >> 2
			B := ((r & 0x3) << 4) | (g >> 4)
			C := ((g & 0xf) << 2) | (b >> 6)
			D := b & 0x3f
			rebuilt := []byte{byte(A + 33), byte(B + 33), byte(C + 33), byte(D + 33)}
			all += string(rebuilt)
			if len(all) == 64 {
				fmt.Printf("\t%q\n", all)
				all = ""
			}
		}
	}
	fmt.Printf("\t%q;\n", all)
}
