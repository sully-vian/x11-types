(* ControlMask is 4, like ButtonPressMask *)
open Mask
let () = create_window ~event_mask:controlMask ()
