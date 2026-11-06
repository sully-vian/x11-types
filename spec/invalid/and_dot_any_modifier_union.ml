(* The user's contract for &.: the result of intersecting with AnyModifier may be
   AnyModifier, which only goes alone. C sends 0x8001 *)
open Mask
let () = grab_key ((anyModifier &. anyModifier) ||| shiftMask)
