let interpret src =
  let len = String.length src in
  let data_ptr = ref 0 in
  let data_stack  = Array.make 30_000 0 in
  let instruction_ptr = ref 0 in
  let instruction_stack  = ref [] in
  while !instruction_ptr < len do
    let () = match src.[!instruction_ptr] with
    | '+' -> data_stack .(!data_ptr) <- data_stack .(!data_ptr) + 1
    | '-' -> data_stack .(!data_ptr) <- data_stack .(!data_ptr) - 1
    | '>' -> incr data_ptr
    | '<' -> decr data_ptr
    | '.' -> print_char @@ char_of_int data_stack .(!data_ptr)
    | ',' -> data_stack .(!data_ptr) <- input_byte stdin
    | '[' ->
      let stack = ref 1 in
      let end_ = ref (!instruction_ptr + 1) in
      let break = ref false in
      let () = while !end_ < len && not !break do
        match src.[!end_] with
        | '[' -> incr stack; incr end_
        | ']' ->
          let () = decr stack in
          if !stack = 0
          then break := true
          else incr end_
        | _ -> incr end_
      done in
      if data_stack .(!data_ptr) = 0
      then instruction_ptr := !end_
      else instruction_stack  := !instruction_ptr :: !instruction_stack 
    | ']' ->
      let () =
        if data_stack .(!data_ptr) <> 0
        then instruction_ptr := List.hd !instruction_stack  - 1
      in
      instruction_stack  := List.tl !instruction_stack 
    | _ -> () in
    incr instruction_ptr
  done

let argv = Sys.argv
let src = argv.(1)
let src, len =
  let fd = open_in src in
  let s = input_line fd in
  let () = close_in fd in
  s, String.length s

let () = interpret src