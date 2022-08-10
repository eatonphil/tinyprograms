package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
)

func interpret(prog []byte) {
	stdin := bufio.NewReader(os.Stdin)
	var dataStack [30_000]byte
	var dataPointer int
	var instructionStack []int
	var instructionPointer int
	for instructionPointer < len(prog) {
		switch prog[instructionPointer] {
		case '>':
			dataPointer++
		case '<':
			dataPointer--
		case '+':
			dataStack[dataPointer]++
		case '-':
			dataStack[dataPointer]--
		case '.':
			fmt.Printf("%s", string(dataStack[dataPointer]))
		case ',':
			c, err := stdin.ReadByte()
			if err != nil && err != io.EOF {
				log.Fatal(err)
			}

			dataStack[dataPointer] = c
		case '[':
			stack := 1
			end := instructionPointer + 1
		loop:
			for {
				switch prog[end] {
				case '[':
					stack++
				case ']':
					stack--

					if stack == 0 {
						break loop
					}
				}

				end++
			}

			if dataStack[dataPointer] == 0 {
				instructionPointer = end
			} else {
				instructionStack = append(instructionStack, instructionPointer)
			}
		case ']':
			if dataStack[dataPointer] != 0 {
				instructionPointer = instructionStack[len(instructionStack)-1] - 1
			}

			instructionStack = instructionStack[:len(instructionStack)-1]
		}

		instructionPointer++
	}
}

func main() {
	prog, err := os.ReadFile(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}

	interpret(prog)
}
