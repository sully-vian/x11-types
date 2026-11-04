(* tinywm: XGrabButton(dpy, 1, Mod1Mask, root, True, ButtonPressMask, ...) *)
open Mask
let () = grab_button mod1Mask buttonPressMask
let () = grab_button anyModifier (buttonPressMask ||| buttonReleaseMask ||| pointerMotionMask)
let () = grab_button noModifier noEventMask
