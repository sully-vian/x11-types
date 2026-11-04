(* ICCCM's WM_DELETE_WINDOW: XSendEvent(dpy, w, False, NoEventMask, &ev).
   EWMH messages to the root: SubstructureRedirectMask | SubstructureNotifyMask *)
open Mask
let () = send_event noEventMask
let () = send_event (substructureRedirectMask ||| substructureNotifyMask)
