(* SETofDEVICEEVENT is a subset of SETofEVENT: XGetWindowAttributes'
   do_not_propagate_mask is also a valid selection. Found outside the spec in
   experiment 4 (LOG.md) *)
open Mask
let attributes = window_attributes ~all:0 ~yours:0 ~dont_propagate:0x4
let () = select_input attributes.do_not_propagate_mask
