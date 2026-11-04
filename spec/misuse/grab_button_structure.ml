(* As for grab_pointer: StructureNotify is dropped, ButtonPress is grabbed *)
open Mask
let () = grab_button mod4Mask (buttonPressMask ||| structureNotifyMask)
