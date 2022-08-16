use std::env;
use std::fs;
use std::io::{self, Read};

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = &args[1];

    let prog: Vec<char> = fs::read_to_string(filename)
        .expect("Could not read file")
        .chars()
        .collect();

    let mut data_stack: [u8; 30_000] = [0; 30_000];
    let mut data_pointer: usize = 0;
    let mut instr_stack: Vec<usize> = Vec::new();
    let mut instr_pointer: usize = 0;

    let mut stdin_buf: [u8; 1] = [0; 1];

    while instr_pointer < prog.len() {
        match prog[instr_pointer] {
            '>' => {
                data_pointer += 1;
            }
            '<' => {
                data_pointer -= 1;
            }
            '+' => {
                data_stack[data_pointer] += 1;
            }
            '-' => {
                data_stack[data_pointer] -= 1;
            }
            '.' => {
                print!("{}", data_stack[data_pointer] as char);
            }
            ',' => {
                io::stdin()
                    .read_exact(&mut stdin_buf)
                    .expect("Could not read from stdin");
                data_stack[data_pointer] = stdin_buf[0];
            }
            '[' => {
                let mut stack = 1;
                let mut end = instr_pointer + 1;
                while stack != 0 {
                    match prog[end] {
                        '[' => {
                            stack += 1;
                        }
                        ']' => {
                            stack -= 1;
                        }
                        _ => {}
                    }

                    end += 1;
                }

                if data_stack[data_pointer] == 0 {
                    instr_pointer = end;
                } else {
                    instr_stack.push(instr_pointer);
                }
            }
            ']' => {
                let new_pointer = instr_stack.pop().unwrap() - 1;
                if data_stack[data_pointer] != 0 {
                    instr_pointer = new_pointer;
                }
            }
            _ => {}
        }

        instr_pointer += 1;
    }
}
