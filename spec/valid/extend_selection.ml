(* Selecting one more event without losing the others:
   XSelectInput(d, w, attrs.your_event_mask | PropertyChangeMask) *)
open Mask
let attributes = window_attributes ~all:0x28000 ~yours:0x20000 ~dont_propagate:0x4
let () = select_input (attributes.your_event_mask ||| propertyChangeMask)
let () = select_input attributes.all_event_masks
let () = change_do_not_propagate (attributes.do_not_propagate_mask ||| keyPressMask)
