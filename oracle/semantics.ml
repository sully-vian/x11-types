(* What a Mask module computes, apart from the X calls: its constants, its
   operators and the masks the server sends. test/conform.t runs it against
   the oracle and mask.ml and diffs the two, so that a design can only change
   types, never values. *)

let int x : int = Obj.magic x
let mask (i : int) = Obj.magic i

let () =
  if not (Obj.is_int (Obj.repr Mask.shiftMask)) then
    failwith "masks must be ints at runtime"

let constants =
  Mask.
    [
      ("noEventMask", int noEventMask);
      ("keyPressMask", int keyPressMask);
      ("keyReleaseMask", int keyReleaseMask);
      ("buttonPressMask", int buttonPressMask);
      ("buttonReleaseMask", int buttonReleaseMask);
      ("enterWindowMask", int enterWindowMask);
      ("leaveWindowMask", int leaveWindowMask);
      ("pointerMotionMask", int pointerMotionMask);
      ("pointerMotionHintMask", int pointerMotionHintMask);
      ("button1MotionMask", int button1MotionMask);
      ("button2MotionMask", int button2MotionMask);
      ("button3MotionMask", int button3MotionMask);
      ("button4MotionMask", int button4MotionMask);
      ("button5MotionMask", int button5MotionMask);
      ("buttonMotionMask", int buttonMotionMask);
      ("keymapStateMask", int keymapStateMask);
      ("exposureMask", int exposureMask);
      ("visibilityChangeMask", int visibilityChangeMask);
      ("structureNotifyMask", int structureNotifyMask);
      ("resizeRedirectMask", int resizeRedirectMask);
      ("substructureNotifyMask", int substructureNotifyMask);
      ("substructureRedirectMask", int substructureRedirectMask);
      ("focusChangeMask", int focusChangeMask);
      ("propertyChangeMask", int propertyChangeMask);
      ("colormapChangeMask", int colormapChangeMask);
      ("ownerGrabButtonMask", int ownerGrabButtonMask);
      ("noModifier", int noModifier);
      ("shiftMask", int shiftMask);
      ("lockMask", int lockMask);
      ("controlMask", int controlMask);
      ("mod1Mask", int mod1Mask);
      ("mod2Mask", int mod2Mask);
      ("mod3Mask", int mod3Mask);
      ("mod4Mask", int mod4Mask);
      ("mod5Mask", int mod5Mask);
      ("button1Mask", int button1Mask);
      ("button2Mask", int button2Mask);
      ("button3Mask", int button3Mask);
      ("button4Mask", int button4Mask);
      ("button5Mask", int button5Mask);
      ("anyModifier", int anyModifier);
    ]

(* Single bits, the XKB group, and masks mixing kinds *)
let samples =
  [ 0; 0x1; 0x41; 0xFF; 0x100; 0x141; 0x2040; 0x6000; 0x8000; 0x7FFC;
    0x20000; 0x1FFFFFF ]

let () =
  List.iter (fun (name, v) -> Printf.printf "%s = 0x%x\n" name v) constants;
  List.iter
    (fun a ->
      Printf.printf "0x%x &. 0xff = 0x%x\n" a (int Mask.(mask a &. mask 0xFF));
      List.iter
        (fun b ->
          Printf.printf "0x%x: ||| 0x%x, &&& %b, &~ 0x%x, &. 0x%x\n" a
            (int Mask.(mask a ||| mask b))
            Mask.(mask a &&& mask b)
            (int Mask.(mask a &~ mask b))
            (int Mask.(mask a &. mask b)))
        samples)
    samples;
  (* The masks the server sends reach the program unchanged *)
  List.iter
    (fun raw ->
      let attributes =
        Mask.window_attributes ~all:raw ~yours:raw ~dont_propagate:raw
      in
      Printf.printf
        "raw 0x%x: key_press 0x%x, button_press 0x%x, query_pointer 0x%x, \
         window_attributes 0x%x 0x%x 0x%x\n"
        raw
        (int (Mask.key_press raw).Mask.state)
        (int (Mask.button_press raw).Mask.state)
        (int (Mask.query_pointer raw))
        (int attributes.Mask.all_event_masks)
        (int attributes.Mask.your_event_mask)
        (int attributes.Mask.do_not_propagate_mask))
    samples
