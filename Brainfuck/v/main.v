module main

import os

fn main() {
	if os.args.len < 2 {
		eprintln("You need to provide the source file")
		exit(1)
	}

	file_name := os.args[1]
	prog := os.read_file(file_name) or {
		eprintln("Error while reading ${file_name}: ${err}")
		exit(1)
	}

	mut stdin := os.stdin()
	mut data_stack := [30_000]u8{}
	mut data_pointer := 0
	mut instruction_stack := []int{}
	mut instruction_pointer := 0

	for instruction_pointer < prog.len {
		match prog[instruction_pointer] {
			`>` { data_pointer += 1 }
			`<` { data_pointer -= 1 }
			`+` { data_stack[data_pointer] += 1 }
			`-` { data_stack[data_pointer] -= 1 }
			`.` { print("${data_stack[data_pointer].ascii_str()}") }
			`,` {
				// read_bytes returns []u8, so we need to index into it.
				b := stdin.read_bytes(1)[0]
				data_stack[data_pointer] = b
			}
			`[` {
				// Try to find the corresponding ]
				mut stack := 1
				mut end := instruction_pointer + 1

				for stack != 0 {
					match prog[end] {
						`[` { stack += 1 }
						`]` { stack -= 1 }
						else { /* should be unreachable */ }
					}
					
					end += 1
				}

				if data_stack[data_pointer] == 0 {
					instruction_pointer = end
				} else {
					instruction_stack << instruction_pointer
				}
			}
			`]` {
				if data_stack[data_pointer] != 0 {
					instruction_pointer = instruction_stack[instruction_stack.len-1] - 1
				}

				instruction_stack = instruction_stack[0..instruction_stack.len-1]
			}	

			else { /* should be unreachable */ }
		}

		instruction_pointer += 1
	}
}
