(* Two annotated narrower masks unioned into a selection, as C's
   XSelectInput(d, w, p | dp). The user's case *)
open Mask
let p : _ pointerEventMask = enterWindowMask
let d : _ deviceEventMask = keyPressMask
let () = select_input (p ||| d)
