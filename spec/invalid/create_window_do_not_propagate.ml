(* EnterWindow isn't a device event: SETofDEVICEEVENT *)
open Mask
let () = create_window ~do_not_propagate_mask:(keyPressMask ||| enterWindowMask) ()
