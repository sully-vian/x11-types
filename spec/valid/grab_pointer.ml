(* tinywm: XGrabPointer(dpy, root, True, PointerMotionMask | ButtonReleaseMask, ...) *)
open Mask
let () = grab_pointer (pointerMotionMask ||| buttonReleaseMask)
let () = grab_pointer noEventMask
(* Every flag of SETofPOINTEREVENT *)
let () =
  grab_pointer
    (buttonPressMask ||| buttonReleaseMask ||| enterWindowMask
   ||| leaveWindowMask ||| pointerMotionMask ||| pointerMotionHintMask
   ||| button1MotionMask ||| button2MotionMask ||| button3MotionMask
   ||| button4MotionMask ||| button5MotionMask ||| buttonMotionMask
   ||| keymapStateMask)
