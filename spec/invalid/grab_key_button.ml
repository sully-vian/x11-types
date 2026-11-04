(* Buttons aren't grab modifiers *)
open Mask
let () = grab_key (shiftMask ||| button1Mask)
