(* The user's contract for &.: a state against a binding's keyMask, which may be
   AnyModifier. C computes state & mod, and the result only holds bits of mod *)
open Mask
let ev = key_press 0x41 (* Mod4 Shift *)
let bindings : keyMask list = [ mod4Mask; anyModifier ]
let () = List.iter (fun (m : keyMask) -> grab_key (ev.state &. m)) bindings
let m : keyMask = mod4Mask
let () = assert (ev.state &. m = mod4Mask)
