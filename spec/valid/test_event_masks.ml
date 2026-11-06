(* Testing a selection against an annotated narrower mask: C's s & p. The
   user's case *)
open Mask
let s : _ eventMask = exposureMask ||| buttonPressMask
let p : _ pointerEventMask = buttonPressMask
let () = assert (s &&& p)
