(* One argument, passed to a pointer grab and extended into a selection: C
   types it unsigned int. The user's case *)
open Mask
let f click =
  grab_pointer click;
  select_input (click ||| exposureMask)
let () = f buttonPressMask
