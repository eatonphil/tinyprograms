package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

func main() {
	prog, err := os.ReadFile(os.Args[1])
	if err != nil {
		panic(err)
	}

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
				panic(err)
			}

			dataStack[dataPointer] = c
		case '[':
			// Find the equivalent (potentially nested) ending ']'
			stack := 1
			end := instructionPointer + 1
			for stack != 0 {
				switch prog[end] {
				case '[':
					stack++
				case ']':
					stack--
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
