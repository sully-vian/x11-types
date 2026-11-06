(* A mask typed for a pointer grab, extended into a selection, as C's
   XSelectInput(d, w, click | ExposureMask). The user's case *)
open Mask
let click : _ pointerEventMask = buttonPressMask ||| buttonReleaseMask
let () = grab_pointer click
let () = select_input (click ||| exposureMask)
