import java.io.FileInputStream;
import java.io.IOException;

public class Main {
  public static void main(final String[] args) throws IOException {
    var file = new FileInputStream("/dev/random");

    var buf = new byte[16];
    var n = file.read(buf);
    if (n != buf.length) {
      System.out.println("Could not read 16 bytes.");
      return;
    }

    // Set bit 6 to 0
    buf[8] &= ~(1 << 6);
    // Set bit 7 to 1
    buf[8] |= 1 << 7;

    // Set version
    buf[6] &= ~(1 << 4);
    buf[6] &= ~(1 << 5);
    buf[6] |= 1 << 6;
    buf[6] &= ~(1 << 7);

    System.out.format(
        "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x\n",
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
        buf[15]);
  }
}
