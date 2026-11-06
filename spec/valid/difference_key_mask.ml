(* sowm's mod_clean on a binding that may be AnyModifier, with the locks in a value
   known not to be: a fold types them as a union, without an annotation. The
   user's decision: &~ doesn't tie its operands' 'c *)
open Mask
let locks = List.fold_left ( ||| ) noModifier [ lockMask; mod2Mask ]
let bindings : keyMask list = [ mod4Mask ||| lockMask; anyModifier ]
let () = List.iter (fun (m : keyMask) -> grab_key (m &~ locks)) bindings
