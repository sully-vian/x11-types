(* A selection extended with a mask typed for a pointer grab, as C's
   XSelectInput(d, w, base | click). The user's case *)
open Mask
let base : _ eventMask = exposureMask
let click : _ pointerEventMask = buttonPressMask
let () = grab_pointer click
let () = select_input (base ||| click)
