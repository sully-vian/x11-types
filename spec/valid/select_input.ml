(* sowm: XSelectInput(d, root, SubstructureRedirectMask) *)
open Mask
let () = select_input (substructureRedirectMask ||| substructureNotifyMask)
let () = select_input noEventMask
(* Every event flag is valid here *)
let () =
  select_input
    (keyPressMask ||| keyReleaseMask ||| buttonPressMask ||| buttonReleaseMask
   ||| enterWindowMask ||| leaveWindowMask ||| pointerMotionMask
   ||| pointerMotionHintMask ||| button1MotionMask ||| button2MotionMask
   ||| button3MotionMask ||| button4MotionMask ||| button5MotionMask
   ||| buttonMotionMask ||| keymapStateMask ||| exposureMask
   ||| visibilityChangeMask ||| structureNotifyMask ||| resizeRedirectMask
   ||| substructureNotifyMask ||| substructureRedirectMask ||| focusChangeMask
   ||| propertyChangeMask ||| colormapChangeMask ||| ownerGrabButtonMask)
