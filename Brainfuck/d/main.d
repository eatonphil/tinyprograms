import std.file: readText;
import std.stdio: printf;

void main(string[] args) {
  string prog = readText(args[1]);

  byte[30_000] data;
  int dataPointer;
  int[] instructionStack;
  int instructionPointer;
  while (instructionPointer < prog.length) {
    switch (prog[instructionPointer]) {
    case '>':
      dataPointer++;
      break;
    case '<':
      dataPointer--;
      break;
    case '+':
      data[dataPointer]++;
      break;
    case '-':
      data[dataPointer]--;
      break;
    case '.':
      printf("%c", data[dataPointer]);
      break;
    case '[':
      // Find the equivalent (potentially nested) ending ']'
      int stack = 1;
      int end = instructionPointer + 1;
    while (stack != 0) {
	switch (prog[end]) {
	case '[':
	  stack++;
	  break;
	case ']':
	  stack--;
	  break;
	default:
	  break;
	}

	end++;
      }

      if (data[dataPointer] == 0) {
	instructionPointer = end;
      } else {
	instructionStack ~= instructionPointer;
      }
      break;
    case ']':
      if (data[dataPointer] != 0) {
	instructionPointer = instructionStack[instructionStack.length-1] - 1;
      }

      instructionStack = instructionStack[0 .. instructionStack.length-1];
      break;
    default:
      break;
    }

    instructionPointer++;
  }
}
