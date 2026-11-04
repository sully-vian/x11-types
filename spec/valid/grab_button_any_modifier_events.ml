(* AnyModifier with an event mask bound as a pointerEventMask: XGrabButton's two
   masks are independent fields. Reported by the user against exp/06, whose
   grab_button shared one 'c between them *)
open Mask
let () =
  let events : pointerEventMask = buttonPressMask ||| buttonReleaseMask in
  grab_button anyModifier events
