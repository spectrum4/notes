package main

import (
	"fmt"
	"image"
	"image/color"
	"image/png"
	"io/ioutil"
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
)

var (
	background = color.RGBA{
		R: 0xcc,
		G: 0xcc,
		B: 0xcc,
		A: 0xff,
	}
	foreground = color.RGBA{
		R: 0x00,
		G: 0x00,
		B: 0x00,
		A: 0xff,
	}
	border = color.RGBA{
		R: 0x66,
		G: 0x66,
		B: 0x66,
		A: 0xff,
	}
)

func main() {
	data, err := ioutil.ReadFile("../font.s")
	if err != nil {
		log.Fatalf("Whoops: %v", err)
	}
	d := [chars][charHeight][charWidth]bool{}
	ch := 0
	line := 0
	lines := strings.Split(strings.Replace(string(data), "\r\n", "\n", -1), "\n")
	for _, s := range lines {
		parts := strings.Fields(s)
		if len(parts) == 2 && parts[0] == ".hword" && strings.HasPrefix(parts[1], "0b") && len(parts[1]) == 2+charWidth {
			for pixel := 0; pixel < charWidth; pixel++ {
				if parts[1][pixel+2] == '1' {
					d[ch][line][pixel] = true
				}
			}
			line += 1
			if line == charHeight {
				line = 0
				ch += 1
			}
			if ch == chars {
				break
			}
			fmt.Println(parts[1][2:])
		}
	}
	im := image.NewRGBA(image.Rectangle{
		Min: image.Point{
			X: 0,
			Y: 0,
		},
		Max: image.Point{
			X: columns*charWidth + (columns+1)*borderWidth,
			Y: rows*charHeight + (rows+1)*borderHeight,
		},
	})

	// Set background colour
	bounds := im.Bounds()
	for j := bounds.Min.Y; j < bounds.Max.Y; j++ {
		for i := bounds.Min.X; i < bounds.Max.X; i++ {
			im.Set(i, j, border)
		}
	}

	for i := 0; i < rows; i++ {
		for j := 0; j < columns; j++ {
			charIndex := j + i*columns - leadingBlankChars
			if charIndex >= 0 && charIndex < chars {
				for k := 0; k < charHeight; k++ {
					for l := 0; l < charWidth; l++ {
						x := borderWidth + l + (borderWidth+charWidth)*j
						y := borderHeight + k + (borderHeight+charHeight)*i
						if d[charIndex][k][l] {
							im.Set(x, y, foreground)
						} else {
							im.Set(x, y, background)
						}
					}
				}
			}
		}
	}

	f, err := os.Create("font.png")
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
