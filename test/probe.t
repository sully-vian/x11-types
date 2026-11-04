The oracle accepts exactly the bits a real X server does (Xvfb, through
Xlib), for every stand-in:

  $ ../probe/run.sh > server
  $ cp ../oracle/mask.ml ../oracle/probe.ml .
  $ ocamlc mask.ml probe.ml -o oracle_probe && ./oracle_probe > oracle
  $ diff server oracle
  $ cat server
  grab_key modifiers: alone 0xffff80ff, with AnyModifier 0xffff0000
  grab_button modifiers: alone 0xffff80ff, with AnyModifier 0xffff0000
  grab_button event_mask: alone 0xffff7ffc
  select_input: alone 0x1ffffff
  grab_pointer: alone 0xffff7ffc
  change_do_not_propagate: alone 0x3f4f
  ungrab_key modifiers: alone 0xffff80ff, with AnyModifier 0xffff0000
  ungrab_button modifiers: alone 0xffff80ff, with AnyModifier 0xffff0000
  change_active_pointer_grab: alone 0xffff7ffc
  send_event: alone 0x1ffffff
  create_window event_mask: alone 0x1ffffff
  create_window do_not_propagate_mask: alone 0x3f4f
  check_mask_event: alone 0xffffffff
