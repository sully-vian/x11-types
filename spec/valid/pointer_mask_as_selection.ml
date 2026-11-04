(* SETofPOINTEREVENT is a subset of SETofEVENT: a mask typed for a pointer grab
   is also a valid selection. Found outside the spec in experiment 4 (LOG.md) *)
open Mask
let p : pointerEventMask = buttonPressMask
let () = grab_pointer p
let () = select_input p
