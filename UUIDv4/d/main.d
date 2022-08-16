import std.stdio: writeln;
import std.format: format;
import std.file: read;

void main() {
  byte[] buf = cast(byte[])read("/dev/random", 16);

  // Set bit 6 to 0
  buf[8] &= ~(1 << 6);
  // Set bit 7 to 1
  buf[8] |= 1 << 7;

  // Set version
  buf[6] &= ~(1 << 4);
  buf[6] &= ~(1 << 5);
  buf[6] |= 1 << 6;
  buf[6] &= ~(1 << 7);

  writeln(format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
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
		 buf[15]));
}
