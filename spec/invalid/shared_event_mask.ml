(* Valid for select_input, not for a pointer grab *)
open Mask
let m = buttonPressMask ||| exposureMask
let () = select_input m
let () = grab_pointer m
