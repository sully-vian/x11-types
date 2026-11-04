(* AnyModifier only goes alone *)
open Mask
let () = grab_key (anyModifier ||| shiftMask)
