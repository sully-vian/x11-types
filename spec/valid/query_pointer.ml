(* XQueryPointer's mask_return tells which buttons are held *)
open Mask
let held = query_pointer (0x100 lor 0x40) (* Button1, Mod4 *)
let () = assert (held &&& button1Mask)
let () = assert (not (held &&& button3Mask))
let () = assert (keys held = keys mod4Mask)
