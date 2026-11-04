(* sowm: XGrabKey(d, code, Mod4Mask | ShiftMask, ...) *)
open Mask
let () = grab_key (mod4Mask ||| shiftMask)
let () = grab_key (shiftMask ||| lockMask ||| controlMask ||| mod1Mask ||| mod2Mask ||| mod3Mask ||| mod4Mask ||| mod5Mask)
