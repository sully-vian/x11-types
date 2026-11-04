(* XQueryPointer's mask holds the buttons too *)
open Mask
let () = grab_key (query_pointer 0x140) (* Button1, Mod4 *)
