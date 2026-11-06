(* XGetWindowAttributes' do_not_propagate_mask extended into a selection:
   XSelectInput(d, w, a.do_not_propagate_mask | ExposureMask). The user's case *)
open Mask
let a = window_attributes ~all:0 ~yours:0 ~dont_propagate:0x4
let () = select_input (a.do_not_propagate_mask ||| exposureMask)
