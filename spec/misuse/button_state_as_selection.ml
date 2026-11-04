(* A button event's state as an event mask: Mod4 is PointerMotion, Button1 is
   Button1Motion, and all of the bits fit SETofEVENT *)
open Mask
let ev = button_press 0x140
let () = select_input ev.state
