(* KeyPress isn't a pointer event *)
open Mask
let () = grab_pointer (buttonPressMask ||| keyPressMask)
