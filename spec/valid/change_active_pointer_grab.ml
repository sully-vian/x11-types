(* During a drag, a window manager changes what its pointer grab reports *)
open Mask
let () = grab_pointer buttonReleaseMask
let () = change_active_pointer_grab (buttonReleaseMask ||| pointerMotionMask)
