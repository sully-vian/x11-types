(* StructureNotify isn't a pointer event, but the event mask travels as CARD16:
   Xlib drops its bit 17 and the server never sees it *)
open Mask
let () = grab_pointer structureNotifyMask
