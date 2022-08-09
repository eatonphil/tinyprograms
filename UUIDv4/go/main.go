package main

import "fmt"
import "os"

func main() {
	f, err := os.Open("/dev/random")
	if err != nil {
		panic(err)
	}

	nBytes := 16
	var bytes []byte
	buf := make([]byte, 1024)
	for len(bytes) != nBytes {
		n, err := f.Read(buf)
		if err != nil {
			panic(err)
		}

		toTake := nBytes - len(bytes)
		if toTake > n {
			toTake = n
		}

		bytes = append(bytes, buf[:toTake]...)
	}

	// Set bit 6 to 0
	bytes[8] &= ^(byte(1) << 6)
	// Set bit 7 to 1
	bytes[8] |= 1 << 7

	// Set version
	bytes[6] &= ^(byte(1) << 4)
	bytes[6] &= ^(byte(1) << 5)
	bytes[6] |= 1 << 6
	bytes[6] &= ^(byte(1) << 7)

	fmt.Printf("%x-%x-%x-%x-%x", bytes[:4], bytes[4:6], bytes[6:8], bytes[8:10], bytes[10:16])
}
