(* The modifiers of an event, reused as a grab: only after keys, since the
   state may hold buttons and the XKB group *)
open Mask
let ev = key_press (0x40 lor 0x1 lor 0x100 lor 0x2000) (* Mod4 Shift Button1, group 1 *)
let () = grab_key (keys ev.state)
