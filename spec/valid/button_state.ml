(* tinywm moves with Mod1 + button 1: the state of a ButtonPress holds the
   modifiers, with the XKB group when a second layout is active *)
open Mask
let modifiers = shiftMask ||| lockMask ||| controlMask ||| mod1Mask ||| mod2Mask ||| mod3Mask ||| mod4Mask ||| mod5Mask
let ev = button_press (0x8 lor 0x2000) (* Mod1, group 1 *)
let () = assert (ev.state &&& mod1Mask)
let () = assert (ev.state &. modifiers = (mod1Mask &. modifiers))
