import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Files;
import java.util.ArrayList;

public class Main {
    public static void main(final String[] args) throws IOException {
	if (args.length < 1) {
	    System.out.println("Expected file name to interpret");
	    return;
	}

	var prog = Files.readString(Path.of(args[0]), StandardCharsets.US_ASCII);

	var dataStack = new byte[30000];
	int dataPointer = 0;

	var instrStack = new ArrayList<Integer>();
	int instrPointer = 0;

	while (instrPointer < prog.length()) {
	    switch (prog.charAt(instrPointer)) {
	    case '>':
		dataPointer++;
		break;
	    case '<':
		dataPointer--;
		break;
	    case '+':
		dataStack[dataPointer]++;
		break;
	    case '-':
		dataStack[dataPointer]--;
		break;
	    case '.':
		System.out.format("%c", dataStack[dataPointer]);
		break;
	    case ',':
		dataStack[dataPointer] = (byte)System.in.read();
		break;
	    case '[':
		var stack = 1;
		var end = instrPointer + 1;
	    loop: while (true) {
		    switch (prog.charAt(end)) {
		    case '[':
			stack++;
			break;
		    case ']':
			stack--;

			if (stack == 0) {
			    break loop;
			}

			break;
		    }

		    end++;
		}

		if (dataStack[dataPointer] == 0) {
		    instrPointer = end;
		} else {
		    instrStack.add(instrPointer);
		}
		break;
	    case ']': 
		int newPointer = instrStack.get(instrStack.size() - 1) - 1;
		instrStack.remove(instrStack.size()-1);
		if (dataStack[dataPointer] != 0) {
		    instrPointer = newPointer;
		}
		break;
	    }

	    instrPointer++;
	}
    }
}
