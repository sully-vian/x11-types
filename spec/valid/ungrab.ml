(* dwm's grabkeys starts with XUngrabKey(dpy, AnyKey, AnyModifier, root), then
   each binding is ungrabbed with the modifiers it was grabbed with *)
open Mask
let () = ungrab_key anyModifier
let () = ungrab_key (mod4Mask ||| shiftMask)
let () = ungrab_button noModifier
let () = ungrab_button anyModifier
