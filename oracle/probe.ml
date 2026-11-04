(* probe/probe.c's report, from the stand-ins of a Mask module instead of a
   server. test/probe.t runs it against the oracle, test/conform.t against
   mask.ml too. Masks are ints at runtime in every design, so Obj.magic passes
   an int whatever the stand-in's type. *)

let mask (i : int) = Obj.magic i

let bad_value request m =
  match request (mask m) with () -> false | exception Failure _ -> true

let report name request ~any_modifier =
  let alone = ref 0 and with_any = ref 0 in
  for b = 0 to 31 do
    if not (bad_value request (1 lsl b)) then alone := !alone lor (1 lsl b);
    if any_modifier && b <> 15
       && not (bad_value request ((1 lsl 15) lor (1 lsl b)))
    then with_any := !with_any lor (1 lsl b)
  done;
  Printf.printf "%s: alone 0x%x" name !alone;
  if any_modifier then Printf.printf ", with AnyModifier 0x%x" !with_any;
  print_newline ()

let () =
  report "grab_key modifiers" Mask.grab_key ~any_modifier:true;
  report "grab_button modifiers"
    (fun m -> Mask.grab_button m (mask 0))
    ~any_modifier:true;
  report "grab_button event_mask" (Mask.grab_button (mask 0))
    ~any_modifier:false;
  report "select_input" Mask.select_input ~any_modifier:false;
  report "grab_pointer" Mask.grab_pointer ~any_modifier:false;
  report "change_do_not_propagate" Mask.change_do_not_propagate
    ~any_modifier:false;
  report "ungrab_key modifiers" Mask.ungrab_key ~any_modifier:true;
  report "ungrab_button modifiers" Mask.ungrab_button ~any_modifier:true;
  report "change_active_pointer_grab" Mask.change_active_pointer_grab
    ~any_modifier:false;
  report "send_event" Mask.send_event ~any_modifier:false;
  report "create_window event_mask"
    (fun m -> Mask.create_window ~event_mask:m ())
    ~any_modifier:false;
  report "create_window do_not_propagate_mask"
    (fun m -> Mask.create_window ~do_not_propagate_mask:m ())
    ~any_modifier:false;
  report "check_mask_event" Mask.check_mask_event ~any_modifier:false
