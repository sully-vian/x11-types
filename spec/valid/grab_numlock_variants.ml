(* dwm and others grab each binding once per CapsLock/NumLock combination,
   with the state's lock flags or-ed into the binding's modifiers *)
open Mask
let binding = mod4Mask
let () =
  List.iter
    (fun locks -> grab_key (binding ||| locks))
    [ noModifier; lockMask; mod2Mask; lockMask ||| mod2Mask ]
