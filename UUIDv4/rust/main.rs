use std::io::{Read};
use std::fs::File;

fn main() {
    let mut f = File::open("/dev/random").expect("Could not open /dev/random");
    let mut buf: [u8;16] = [0; 16];
    
    // Read file into vector.
    f.read_exact(&mut buf).expect("Could not read 16 bytes");

    // Set bit 6 to 0
    buf[8] &= !((1 as u8) << 6);
    // Set bit 7 to 1
    buf[8] |= 1 << 7;

    // Set version
    buf[6] &= !((1 as u8) << 4);
    buf[6] &= !((1 as u8) << 5);
    buf[6] |= 1 << 6;
    buf[6] &= !((1 as u8) << 7);

    print!("{:02x}{:02x}{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}{:02x}{:02x}{:02x}{:02x}",
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
	   buf[15],
    )
}
