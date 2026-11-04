(* Xlib never sends this mask, so nothing fails: ShiftMask filters KeyPress *)
open Mask
let () = check_mask_event shiftMask
