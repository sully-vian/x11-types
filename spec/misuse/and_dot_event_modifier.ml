(* The user's contract for &.: its first operand is a state or modifiers.
   KeyPressMask is 1, like ShiftMask, so C computes 1 *)
open Mask
let _ = keyPressMask &. shiftMask
