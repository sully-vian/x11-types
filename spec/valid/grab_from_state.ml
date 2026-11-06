(* The modifiers of an event, reused as a grab: only after &., since the
   state may hold buttons and the XKB group *)
open Mask
let modifiers = shiftMask ||| lockMask ||| controlMask ||| mod1Mask ||| mod2Mask ||| mod3Mask ||| mod4Mask ||| mod5Mask
let ev = key_press (0x40 lor 0x1 lor 0x100 lor 0x2000) (* Mod4 Shift Button1, group 1 *)
let () = grab_key (ev.state &. modifiers)
