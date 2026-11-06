(* sowm's table of shortcuts: a struct field holding the modifiers, or-ed with the
   lock masks when grabbing, keys[i].mod | LockMask. The user's case *)
open Mask
type key = { m : bindingMask; action : string }
let k = { m = mod4Mask ||| shiftMask; action = "kill" }
let () = grab_key k.m
let () = grab_key (k.m ||| lockMask)
let () = assert (k.action = "kill")
