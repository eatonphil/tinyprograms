const std = @import("std");

const k = [64]u32{
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

const Sha256 = struct {
    data:    [64]u8,
    datalen: u32,
    bitlen:  u64,
    state:   [8]u32,

    fn compute(ctx *sha256Context, data [64]u8) {
	var i, j, t1, t2 u32
	var w [64]u32

	for i = 0; i < 16; i++ {
		w[i] = (u32(data[j]) << 24) | (u32(data[j+1]) << 16) | (u32(data[j+2]) << 8) | u32(data[j+3])
		j += 4
	}
	for ; i < 64; i++ {
		w[i] = σ1(w[i-2]) + w[i-7] + σ0(w[i-15]) + w[i-16]
	}

	a := ctx.state[0]
	b := ctx.state[1]
	c := ctx.state[2]
	d := ctx.state[3]
	e := ctx.state[4]
	f := ctx.state[5]
	g := ctx.state[6]
	h := ctx.state[7]

	for i = 0; i < 64; i++ {
		t1 = h + Σ1(e) + ch(e, f, g) + k[i] + w[i]
		t2 = Σ0(a) + maj(a, b, c)
		h = g
		g = f
		f = e
		e = d + t1
		d = c
		c = b
		b = a
		a = t1 + t2
	}

	ctx.state[0] += a
	ctx.state[1] += b
	ctx.state[2] += c
	ctx.state[3] += d
	ctx.state[4] += e
	ctx.state[5] += f
	ctx.state[6] += g
	ctx.state[7] += h
    }
    
fn SHA256(data: []u8) [32]u8 {
	ctx := sha256Context{}
	ctx.state[0] = 0x6a09e667
	ctx.state[1] = 0xbb67ae85
	ctx.state[2] = 0x3c6ef372
	ctx.state[3] = 0xa54ff53a
	ctx.state[4] = 0x510e527f
	ctx.state[5] = 0x9b05688c
	ctx.state[6] = 0x1f83d9ab
	ctx.state[7] = 0x5be0cd19

	var i u32
	for i = 0; i < u32(len(data)); i++ {
		ctx.data[ctx.datalen] = data[i]
		ctx.datalen++
		if ctx.datalen == 64 {
			ctx.sha256Compute(ctx.data)
			ctx.bitlen += 512
			ctx.datalen = 0
		}
	}

	i = ctx.datalen

	// Add padding and message length to the end of the message and compute once more
	if ctx.datalen < 56 {
		ctx.data[i] = 0x80
		i++
		for i < 56 {
			ctx.data[i] = 0x00
			i++
		}
	} else {
		ctx.data[i] = 0x80
		i++
		for i < 64 {
			ctx.data[i] = 0x00
			i++
		}
		ctx.sha256Compute(ctx.data)
		for i := 0; i < 56; i++ {
			ctx.data[i] = 0
		}
	}

	ctx.bitlen += u64(ctx.datalen * 8)
	ctx.data[63] = u8(ctx.bitlen)
	ctx.data[62] = u8(ctx.bitlen >> 8)
	ctx.data[61] = u8(ctx.bitlen >> 16)
	ctx.data[60] = u8(ctx.bitlen >> 24)
	ctx.data[59] = u8(ctx.bitlen >> 32)
	ctx.data[58] = u8(ctx.bitlen >> 40)
	ctx.data[57] = u8(ctx.bitlen >> 48)
	ctx.data[56] = u8(ctx.bitlen >> 56)
	ctx.sha256Compute(ctx.data)

	var hash [32]u8
	for i = 0; i < 4; i++ {
		hash[i] = u8((ctx.state[0] >> (24 - i*8)) & 0x000000ff)
		hash[i+4] = u8((ctx.state[1] >> (24 - i*8)) & 0x000000ff)
		hash[i+8] = u8((ctx.state[2] >> (24 - i*8)) & 0x000000ff)
		hash[i+12] = u8((ctx.state[3] >> (24 - i*8)) & 0x000000ff)
		hash[i+16] = u8((ctx.state[4] >> (24 - i*8)) & 0x000000ff)
		hash[i+20] = u8((ctx.state[5] >> (24 - i*8)) & 0x000000ff)
		hash[i+24] = u8((ctx.state[6] >> (24 - i*8)) & 0x000000ff)
		hash[i+28] = u8((ctx.state[7] >> (24 - i*8)) & 0x000000ff)
	}
	return hash
    }
};

fn rotL(a: u32, b: u32) u32 {
	return (a << b) | (a >> (32 - b))
}
fn rotR(a: u32, b: u32) u32 {
	return (a >> b) | (a << (32 - b))
}
fn ch(x: u32, y: u32, z: u32) u32 {
	return (x & y) ^ (^x & z)
}
fn maj(x:u32, y:u32, z: u32) u32 {
	return (x & y) ^ (x & z) ^ (y & z)
}
fn Σ0(x: u32) u32 {
	return rotR(x, 2) ^ rotR(x, 13) ^ rotR(x, 22)
}
fn Σ1(x: u32) u32 {
	return rotR(x, 6) ^ rotR(x, 11) ^ rotR(x, 25)
}
fn σ0(x: u32) u32 {
	return rotR(x, 7) ^ rotR(x, 18) ^ (x >> 3)
}
fn σ1(x: u32) u32 {
	return rotR(x, 17) ^ rotR(x, 19) ^ (x >> 10)
}

fn main() {
	in, err := os.ReadFile(os.Args[1])
	if err != nil {
		panic(err)
	}

	fmt.Printf("%x\n", SHA256(in))
}
