(* Exposure isn't a pointer event, and its bit 15 fits in the CARD16 *)
open Mask
let () = grab_pointer (buttonPressMask ||| exposureMask)
