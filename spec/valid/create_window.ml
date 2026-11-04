(* XCreateWindow with CWEventMask | CWDontPropagate *)
open Mask
let () =
  create_window ~event_mask:(exposureMask ||| keyPressMask)
    ~do_not_propagate_mask:buttonPressMask ()
let () = create_window ()
