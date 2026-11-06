(* A state tested against an annotated binding: C's e.state & m. The user's case *)
open Mask
let e = key_press 0x41 (* Mod4 Shift *)
let m : _ keyMask = mod4Mask
let () = grab_key m
let () = assert (e.state &&& m)
