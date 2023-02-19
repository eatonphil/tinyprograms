import Foundation

let file = CommandLine.arguments[1]
let prog: [UInt8] = Array((try String(contentsOfFile: file)).utf8)

var dataStack: [UInt8] = Array(repeating: 0, count: 30_000)
var dataPointer = 0
var instructionStack: [Int] = []
var instructionPointer = 0

while instructionPointer < prog.count {
    switch prog[instructionPointer] {
    case UInt8(ascii: ">"):
        dataPointer += 1
    case UInt8(ascii: "<"):
        dataPointer -= 1
    case UInt8(ascii: "+"):
        dataStack[dataPointer] += 1
    case UInt8(ascii: "-"):
        dataStack[dataPointer] -= 1
    case UInt8(ascii: "."):
        print(String(bytes: [dataStack[dataPointer]], encoding: .utf8)!, terminator: "")
    case UInt8(ascii: ","):
        assert(false)
    case UInt8(ascii: "["):
        // Find the equivalent (potentially nested) ending "]"
        var stack = 1
        var end = instructionPointer + 1
        while stack != 0 {
            switch prog[end] {
            case UInt8(ascii: "["):
                stack += 1
            case UInt8(ascii: "]"):
                stack -= 1
            default:
                break
            }

            end += 1
        }

        if dataStack[dataPointer] == 0 {
            instructionPointer = end
        } else {
            instructionStack.append(instructionPointer)
        }
    case UInt8(ascii: "]"):
        if dataStack[dataPointer] != 0 {
            instructionPointer = instructionStack[instructionStack.count-1] - 1
        }

        instructionStack = Array(instructionStack[0..<instructionStack.count-1])
    default:
        print("bad character", prog[instructionPointer])
        exit(1)
    }

    instructionPointer += 1
}
