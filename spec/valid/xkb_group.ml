(* With a second layout active, the server sets the XKB group in bits 13-14 of
   an event's state *)
open Mask
let modifiers = shiftMask ||| lockMask ||| controlMask ||| mod1Mask ||| mod2Mask ||| mod3Mask ||| mod4Mask ||| mod5Mask
let ev = key_press (0x40 lor 0x2000) (* Mod4, group 1 *)
let () = assert (ev.state &. modifiers = (mod4Mask &. modifiers))
