let encode_6bits = function
| 0 -> "A"  | 1 -> "B"  | 2 -> "C"  | 3 -> "D"  | 4 -> "E"  | 5 -> "F"
| 6 -> "G"  | 7 -> "H"  | 8 -> "I"  | 9 -> "J"  | 10 -> "K" | 11 -> "L"
| 12 -> "M" | 13 -> "N" | 14 -> "O" | 15 -> "P" | 16 -> "Q" | 17 -> "R"
| 18 -> "S" | 19 -> "T" | 20 -> "U" | 21 -> "V" | 22 -> "W" | 23 -> "X"
| 24 -> "Y" | 25 -> "Z" | 26 -> "a" | 27 -> "b" | 28 -> "c" | 29 -> "d"
| 30 -> "e" | 31 -> "f" | 32 -> "g" | 33 -> "h" | 34 -> "i" | 35 -> "j"
| 36 -> "k" | 37 -> "l" | 38 -> "m" | 39 -> "n" | 40 -> "o" | 41 -> "p"
| 42 -> "q" | 43 -> "r" | 44 -> "s" | 45 -> "t" | 46 -> "u" | 47 -> "v"
| 48 -> "w" | 49 -> "x" | 50 -> "y" | 51 -> "z" | 52 -> "0" | 53 -> "1"
| 54 -> "2" | 55 -> "3" | 56 -> "4" | 57 -> "5" | 58 -> "6" | 59 -> "7"
| 60 -> "8" | 61 -> "9" | 62 -> "+" | 63 -> "/"
| _ -> failwith "invalid 6 bit encoding."

let bitmask24_1 b = (0b111111_000000_000000_000000 land b) lsr 18
let bitmask24_2 b = (0b000000_111111_000000_000000 land b) lsr 12
let bitmask24_3 b = (0b000000_000000_111111_000000 land b) lsr 6
let bitmask24_4 b = 0b000000_000000_000000_111111 land b

let bitmask18_1 b = (0b111111_000000_000000 land b) lsr 12
let bitmask18_2 b = (0b000000_111111_000000 land b) lsr 6
let bitmask18_3 b = 0b000000_000000_111111 land b

let bitmask12_1 b = (0b111111_000000 land b) lsr 6
let bitmask12_2 b = 0b000000_111111 land b

let encode : bytes -> string =
  fun buf ->
    let len = Bytes.length buf in
    let rec aux i =
      if len - i = 0 then ""
      else if len - i = 1 then
        let b = Bytes.get_int8 buf i in
        let b = b lsl 4 in
        encode_6bits (bitmask12_1 b) ^ 
        encode_6bits (bitmask12_2 b) ^ "=="
      else if len - i = 2 then
        let b = Bytes.get_int16_be buf i in
        let b = b lsl 2 in
        encode_6bits (bitmask18_1 b) ^ 
        encode_6bits (bitmask18_2 b) ^ 
        encode_6bits (bitmask18_3 b) ^ "="
      else
        let b = Bytes.sub buf i 3 in
        let b' = (Bytes.get_int16_be b 0) lsl 8 in
        let b = b' + (Bytes.get_int8 b 2) in
        encode_6bits (bitmask24_1 b) ^
        encode_6bits (bitmask24_2 b) ^
        encode_6bits (bitmask24_3 b) ^
        encode_6bits (bitmask24_4 b) ^ aux (i + 3)
    in
    aux 0

let () = assert ("SGVsbG8=" = (encode (Bytes.of_string "Hello")))
let () = assert ("bGlnaHQgd29yay4=" = (encode (Bytes.of_string "light work.")))
let () = assert ("bGlnaHQgd29yaw==" = (encode (Bytes.of_string "light work")))
let () = assert ("bGlnaHQgd29y" = (encode (Bytes.of_string "light wor")))
let () = assert ("bGlnaHQgd28=" = (encode (Bytes.of_string "light wo")))
let () = assert ("bGlnaHQgdw==" = (encode (Bytes.of_string "light w")))

let decode_6bits = function
| 'A' -> 0  | 'B' -> 1  | 'C' -> 2  | 'D' -> 3  | 'E' -> 4  | 'F' -> 5
| 'G' -> 6  | 'H' -> 7  | 'I' -> 8  | 'J' -> 9  | 'K' -> 10 | 'L' -> 11 
| 'M' -> 12 | 'N' -> 13 | 'O' -> 14 | 'P' -> 15 | 'Q' -> 16 | 'R' -> 17
| 'S' -> 18 | 'T' -> 19 | 'U' -> 20 | 'V' -> 21 | 'W' -> 22 | 'X' -> 23
| 'Y' -> 24 | 'Z' -> 25 | 'a' -> 26 | 'b' -> 27 | 'c' -> 28 | 'd' -> 29
| 'e' -> 30 | 'f' -> 31 | 'g' -> 32 | 'h' -> 33 | 'i' -> 34 | 'j' -> 35
| 'k' -> 36 | 'l' -> 37 | 'm' -> 38 | 'n' -> 39 | 'o' -> 40 | 'p' -> 41
| 'q' -> 42 | 'r' -> 43 | 's' -> 44 | 't' -> 45 | 'u' -> 46 | 'v' -> 47
| 'w' -> 48 | 'x' -> 49 | 'y' -> 50 | 'z' -> 51 | '0' -> 52 | '1' -> 53
| '2' -> 54 | '3' -> 55 | '4' -> 56 | '5' -> 57 | '6' -> 58 | '7' -> 59
| '8' -> 60 | '9' -> 61 | '+' -> 62 | '/' -> 63 
| _ -> failwith "invalid 6 bit encoding."

let decode : string -> bytes =
  fun b64 ->
    let slen = String.length b64 in
    if slen = 0 then Bytes.create 0 else
    let slen, blen = 
      let blen = slen * 6 in
      if b64.[slen - 2] = '=' && b64.[slen - 1] = '='
      then slen - 2, (blen - 16) / 8
      else if b64.[slen - 1] = '='
      then slen - 1, (blen - 8) / 8
      else slen, blen / 8
    in
    let buf = Bytes.create blen in
    let () = Bytes.fill buf 0 blen '\x00' in
    let rec aux i ib x bs =
      if i = slen then
        if ib <> blen then
          Bytes.set buf ib (char_of_int (x lsl bs))
        else ()
      else
        let dec = decode_6bits b64.[i] in
        let bs, (), xs, ib = 
          if bs = 6 then
            let dec2 = ((dec land 0b11_0000) lsr 4) in
            let x = (x lsl 2) + dec2 in 
            4, Bytes.set buf ib (char_of_int x), dec land 0b00_1111, ib + 1
          else if bs = 4 then
            let dec4 = ((dec land 0b1111_00) lsr 2) in
            let x = (x lsl 4) + dec4 in
            2, Bytes.set buf ib (char_of_int x), dec land 0b0000_11, ib + 1
          else if bs = 2 then
            let x = (x lsl 6) + dec in
            0, Bytes.set buf ib (char_of_int x), 0, ib + 1
          else if bs = 0 then
            6, (), dec, ib
          else failwith ("invalid bs: " ^ string_of_int bs)
        in 
        aux (i + 1) ib xs bs
    in
    let () = aux 1 0 (decode_6bits b64.[0]) 6 in
    buf

(* https://en.wikipedia.org/wiki/Base64#Examples *)
let () = assert (Bytes.to_string (decode "TQ==") = "M")
let () = assert (Bytes.to_string (decode "TWE=") = "Ma")
let () = assert (Bytes.to_string (decode "TWFu") = "Man")

let () = assert ((Bytes.to_string (decode "SGVsbG8=")) = "Hello")
let () = assert ((Bytes.to_string (decode "bGlnaHQgd29yay4=")) = "light work.")
let () = assert ((Bytes.to_string (decode "bGlnaHQgd29yaw==")) = "light work")
let () = assert ((Bytes.to_string (decode "bGlnaHQgd29y" )) = "light wor")
let () = assert ((Bytes.to_string (decode "bGlnaHQgd28=")) = "light wo")
let () = assert ((Bytes.to_string (decode "bGlnaHQgdw==")) = "light w")


let encode_decode s =
  let e = encode (Bytes.of_string s) in
  let d = decode e in
  let s' = Bytes.to_string d in
  assert (s = s')

let () = encode_decode "Hello"
let () = encode_decode "a\nb\nc"
let () = encode_decode "a\tb\nc"
let () = encode_decode "Many hands make light work."

let () = print_endline "Done :)"