(* Every flag of SETofDEVICEEVENT *)
open Mask
let () =
  change_do_not_propagate
    (keyPressMask ||| keyReleaseMask ||| buttonPressMask ||| buttonReleaseMask
   ||| pointerMotionMask ||| button1MotionMask ||| button2MotionMask
   ||| button3MotionMask ||| button4MotionMask ||| button5MotionMask
   ||| buttonMotionMask)
