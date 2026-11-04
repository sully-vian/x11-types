(* sowm binds the XF86 media keys with no modifier: XGrabKey(d, code, 0, ...) *)
open Mask
let () = grab_key noModifier
