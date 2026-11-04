(* A selection isn't a set of device events: here it holds StructureNotify *)
open Mask
let attributes = window_attributes ~all:0x20004 ~yours:0x20004 ~dont_propagate:0
let () = change_do_not_propagate attributes.your_event_mask
