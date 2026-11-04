(* EnterWindow isn't a device event: SETofDEVICEEVENT *)
open Mask
let () = change_do_not_propagate enterWindowMask
