(* A config table, as sowm's keys[]: grab every entry, including AnyModifier,
   then find the one an event matches *)
open Mask
let bindings = [ (mod4Mask, "focus"); (mod4Mask ||| shiftMask, "kill"); (anyModifier, "media") ]
let () = List.iter (fun (m, _) -> grab_key m) bindings
let ev = key_press 0x41
let () =
  assert (
    List.find_map
      (fun (m, action) -> if m <> anyModifier && keys m = keys ev.state then Some action else None)
      bindings
    = Some "kill")
