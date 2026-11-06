(* Testing a binding that may be AnyModifier against locks known not to be: a fold
   types them as a union, without an annotation. The user's decision: &&& doesn't
   tie its operands' 'c *)
open Mask
let locks = List.fold_left ( ||| ) noModifier [ lockMask; mod2Mask ]
let bindings : _ keyMask list = [ mod4Mask ||| lockMask; anyModifier ]
let () = assert (List.map (fun (m : _ keyMask) -> m &&& locks) bindings = [ true; false ])
