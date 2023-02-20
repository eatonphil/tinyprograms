import Foundation

guard let f = FileHandle(forReadingAtPath: "/dev/random") else {
    print("Could not open /dev/random")
    exit(1)
}

guard let read = try f.read(upToCount: 16) else {
    print("Could not read any bytes")
    exit(1)
}

if read.count != 16 {
    print("Could not read 16 bytes")
    exit(1)
}
var buf: [UInt8] = Array(read)

// Set bit 6 to 0
buf[8] &= ~(1 << 6)
// Set bit 7 to 1
buf[8] |= 1 << 7

// Set version
buf[6] &= ~(1 << 4)
buf[6] &= ~(1 << 5)
buf[6] |= 1 << 6
buf[6] &= ~(1 << 7)

print(String(format: "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
	     buf[0],
	     buf[1],
	     buf[2],
	     buf[3],
	     // -
	     buf[4],
	     buf[5],
	     // - 
	     buf[6],
	     buf[7],
	     // -
	     buf[8],
	     buf[9],
	     // -
	     buf[10],
	     buf[11],
	     buf[12],
	     buf[13],
	     buf[14],
	     buf[15]))
