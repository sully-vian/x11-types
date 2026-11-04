(* C's accumulating loop, for (...) mods |= flags[i], before XGrabKey. Found
   outside the spec in experiment 4 (LOG.md): the fold ties the accumulator's
   type to the operands of ||| *)
open Mask
let all = List.fold_left ( ||| ) noModifier [ shiftMask; lockMask ]
let () = grab_key all
