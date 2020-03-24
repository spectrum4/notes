package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

func main() {
	resp, err := http.Get("http://mdfs.net/Software/Spectrum/ROMImages/48k.rom")
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	fmt.Println(strings.Repeat("+--------", 12) + "+")
	for b := 0; b < 8; b++ {
		for i := 0; i < 8; i++ {
			str := make([]string, 12, 12)
			for k := 0; k < 12; k++ {
				str[k] = ""
				v := data[b*96+k*8+i+15616]
				for j := 0; j < 8; j++ {
					bit := v % 2
					if bit == 1 {
						str[k] = "◙" + str[k]
					} else {
						str[k] = " " + str[k]
					}
					v = v >> 1
				}
			}
			fmt.Println("|" + strings.Join(str, "|") + "|")
		}
		fmt.Println(strings.Repeat("+--------", 12) + "+")
	}
}
