(* Ungrabbing checks the modifiers as grabbing does *)
open Mask
let () = ungrab_key (mod4Mask ||| button1Mask)
