(* sowm drops queued crossing events: XCheckTypedEvent; with a mask, as dwm's
   drawbar: while (XCheckMaskEvent(dpy, EnterWindowMask, &ev)); *)
open Mask
let () = check_mask_event enterWindowMask
let () = check_mask_event (pointerMotionMask ||| enterWindowMask)
