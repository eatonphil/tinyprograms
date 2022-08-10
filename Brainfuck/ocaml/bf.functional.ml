type state = { tape : int array ; ptr : int ; out : string }
let initial_state () = { tape = Array.make 30_000 0 ; ptr = 0 ; out = "" }

let rec interpret ~src ~len pos state loop_stack =
  if pos >= len then state
  else
    let { tape ; ptr ; out } = state in
    let pos, state, loop_stack = match src.[pos] with
    | '+' ->
      let () = tape.(ptr) <- tape.(ptr) + 1 in
      let state = { state with tape } in
      pos, state, loop_stack
    | '-' ->
      let () = tape.(ptr) <- tape.(ptr) - 1 in
      let state = { state with tape } in
      pos, state, loop_stack
    | '>' ->
      let state = { state with ptr = ptr + 1 } in
      pos, state, loop_stack
    | '<' ->
      let state = { state with ptr = ptr - 1 } in
      pos, state, loop_stack
    | '.' ->
      let c = String.make 1 (char_of_int tape.(ptr)) in
      let out = out ^ c in
      let state = { state with out } in
      pos, state, loop_stack
    | ',' ->
      let inp = input_byte stdin in
      let () = tape.(ptr) <- inp in
      let state = { state with tape } in
      pos, state, loop_stack
    | '[' ->
      if tape.(ptr) = 0
      then
        let pos = loop_end_pos ~src ~len pos 0 in
        pos, state, loop_stack
      else
        let loop_stack = pos :: loop_stack in
        pos, state, loop_stack
    | ']' ->
      if tape.(ptr) <> 0
      then
        let pos = List.hd loop_stack in
        pos, state, loop_stack
      else
        let loop_stack = List.tl loop_stack in
        pos, state, loop_stack
    | _ -> pos, state, loop_stack
  in
  interpret ~src ~len (pos + 1) state loop_stack

and loop_end_pos ~src ~len pos level =
    if pos >= len then pos - 1
    else
      if src.[pos] = ']' && level = 0 then pos
      else if src.[pos] = '['
      then loop_end_pos ~src ~len (pos + 1) (level + 1)
      else if src.[pos] = ']'
      then loop_end_pos ~src ~len (pos + 1) (level - 1)
      else loop_end_pos ~src ~len (pos + 1) level

let argv = Sys.argv
let src = argv.(1)
let src, len =
  let fd = open_in src in
  let s = input_line fd in
  let () = close_in fd in
  s, String.length s

let { out ; _ } = interpret ~src ~len 0 (initial_state ()) []

let () = print_string out
