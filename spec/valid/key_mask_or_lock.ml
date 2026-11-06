(* An annotated binding that isn't AnyModifier, grabbed with NumLock, as dwm's
   mod | numlockmask. The user's case *)
open Mask
let m : _ keyMask = mod4Mask
let () = grab_key (m ||| mod2Mask)
