(* The user's contract for &.: AnyModifier isn't a set of modifiers to keep. C
   computes ShiftMask & AnyModifier = 0, valid in every field, so no call on it
   can get a BadValue: rule 3, not rule 1 *)
open Mask
let _ = shiftMask &. anyModifier
