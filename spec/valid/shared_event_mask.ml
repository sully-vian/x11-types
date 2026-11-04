(* One mask, bound once, passed where two protocol sets overlap *)
open Mask
let m = buttonPressMask ||| pointerMotionMask
let () = select_input m
let () = grab_pointer m
let () = grab_button mod4Mask m
