(* Removing an annotated narrower mask from a selection: C's s & ~p. The
   user's case *)
open Mask
let s : _ eventMask = exposureMask ||| buttonPressMask
let p : _ pointerEventMask = buttonPressMask
let () = select_input (s &~ p)
