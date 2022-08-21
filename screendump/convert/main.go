package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {
	data := [213840]byte{}
	for i := 0; i < 207360; i++ {
		data[i] = 0
	}
	for i := 207360; i < 213840; i++ {
		data[i] = 0x38
	}

	readFile, err := os.Open("log")
	if err != nil {
		log.Fatal(err)
	}
	fileScanner := bufio.NewScanner(readFile)
	for fileScanner.Scan() {
		line := fileScanner.Text()
		addressStr := line[2:18]
		address, err := strconv.ParseInt(addressStr, 16, 64)
		if err != nil {
			log.Fatal(err)
		}
		offset := address - 0x4540
		for a := int64(0); a < 8; a++ {
			valueStr := line[35-a*2 : 37-a*2]
			value, err := strconv.ParseInt(valueStr, 16, 64)
			if err != nil {
				log.Fatal(err)
			}
			data[offset+a] = byte(value)
		}
	}
	readFile.Close()
	err = os.WriteFile("../screenshot/input", data[:], 0644)
	if err != nil {
		log.Fatal(err)
	}
	count := 0
	j := uint64(data[0]) + uint64(data[1])<<8 + uint64(data[2])<<16 + uint64(data[3])<<24 + uint64(data[4])<<32 + uint64(data[5])<<40 + uint64(data[6])<<48 + uint64(data[7])<<56
	var oldj uint64
	for i := 8; i < 213840; i += 8 {
        oldj = j
		j = uint64(data[i]) + uint64(data[i+1])<<8 + uint64(data[i+2])<<16 + uint64(data[i+3])<<24 + uint64(data[i+4])<<32 + uint64(data[i+5])<<40 + uint64(data[i+6])<<48 + uint64(data[i+7])<<56
		if j != oldj {
			if count == 0 {
				fmt.Printf("0x%016x ", oldj)
			} else {
				fmt.Printf("0x6a09e667bb67ae85 0x%016x 0x%016x ", count, oldj)
			}
			count = 0
		} else {
			count += 1
		}
	}
	if count == 0 {
		fmt.Printf("0x%016x ", j)
	} else {
		fmt.Printf("0x6a09e667bb67ae85 0x%016x 0x%016x ", count, j)
	}
}
