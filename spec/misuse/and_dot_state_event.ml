(* The user's contract for &.: its second operand holds modifiers. ExposureMask
   isn't one, though C computes state & ExposureMask without complaint *)
open Mask
let e = key_press 0x41
let _ = e.state &. exposureMask
