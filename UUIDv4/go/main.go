package main

import (
	"fmt"
	"os"
)

func main() {
	f, err := os.Open("/dev/random")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	buf := make([]byte, 16)
	n, err := f.Read(buf)
	if err != nil {
		panic(err)
	}

	if n != len(buf) {
		panic("Expected 16 bytes")
	}

	// Set bit 6 to 0
	buf[8] &= ^(byte(1) << 6)
	// Set bit 7 to 1
	buf[8] |= 1 << 7

	// Set version
	buf[6] &= ^(byte(1) << 4)
	buf[6] &= ^(byte(1) << 5)
	buf[6] |= 1 << 6
	buf[6] &= ^(byte(1) << 7)

	fmt.Printf("%x-%x-%x-%x-%x",
		buf[:4],
		buf[4:6],
		buf[6:8],
		buf[8:10],
		buf[10:16])
}
