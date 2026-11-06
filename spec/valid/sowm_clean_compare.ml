(* sowm's key handler:
     mod_clean(keys[i].mod) == mod_clean(e->xkey.state)
   mod_clean drops NumLock and CapsLock, and keeps only Shift, Control and
   Mod1..Mod5. The binding is a grab mask, the state an event's. *)
open Mask
let modifiers = shiftMask ||| lockMask ||| controlMask ||| mod1Mask ||| mod2Mask ||| mod3Mask ||| mod4Mask ||| mod5Mask
let binding = mod4Mask ||| shiftMask
let () = grab_key binding
let clean m = (m &~ (lockMask ||| mod2Mask)) &. modifiers
let ev = key_press (0x40 lor 0x1 lor 0x2 lor 0x10 lor 0x100) (* Mod4 Shift Lock Mod2 Button1 *)
let () = assert (clean ev.state = clean binding)
let () = assert (ev.state &&& shiftMask && not (ev.state &&& controlMask))
