(* An event's state may hold buttons and the XKB group *)
open Mask
let ev = key_press 0x141 (* Mod4 Shift Button1 *)
let () = grab_key ev.state
