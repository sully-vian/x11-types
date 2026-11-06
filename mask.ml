type (+'a, +'c) mask = int
type union
type alone

type 'c keyMask = ([ `Key ], 'c) mask
type stateMask = ([ `Key | `Button ], union) mask
type eventFlags = [ `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ]
type pointerEventFlags = [ `PointerEvent | `PointerDeviceEvent ]
type deviceEventFlags = [ `DeviceEvent | `PointerDeviceEvent ]
type 'a eventMask = (([> eventFlags ] as 'a), union) mask
type 'a pointerEventMask = (([> pointerEventFlags ] as 'a), union) mask
type 'a deviceEventMask = (([> deviceEventFlags ] as 'a), union) mask

let ( ||| ) = ( lor )
let ( &&& ) m flags = m land flags <> 0
let ( &~ ) m flags = m land lnot flags

(* sowm's mod_clean keeps Shift, Control and Mod1..Mod5 *)
let ( &. ) m flags = m land flags

(* X.h *)
let noEventMask = 0
let keyPressMask = 1 lsl 0
let keyReleaseMask = 1 lsl 1
let buttonPressMask = 1 lsl 2
let buttonReleaseMask = 1 lsl 3
let enterWindowMask = 1 lsl 4
let leaveWindowMask = 1 lsl 5
let pointerMotionMask = 1 lsl 6
let pointerMotionHintMask = 1 lsl 7
let button1MotionMask = 1 lsl 8
let button2MotionMask = 1 lsl 9
let button3MotionMask = 1 lsl 10
let button4MotionMask = 1 lsl 11
let button5MotionMask = 1 lsl 12
let buttonMotionMask = 1 lsl 13
let keymapStateMask = 1 lsl 14
let exposureMask = 1 lsl 15
let visibilityChangeMask = 1 lsl 16
let structureNotifyMask = 1 lsl 17
let resizeRedirectMask = 1 lsl 18
let substructureNotifyMask = 1 lsl 19
let substructureRedirectMask = 1 lsl 20
let focusChangeMask = 1 lsl 21
let propertyChangeMask = 1 lsl 22
let colormapChangeMask = 1 lsl 23
let ownerGrabButtonMask = 1 lsl 24
let noModifier = 0
let shiftMask = 1 lsl 0
let lockMask = 1 lsl 1
let controlMask = 1 lsl 2
let mod1Mask = 1 lsl 3
let mod2Mask = 1 lsl 4
let mod3Mask = 1 lsl 5
let mod4Mask = 1 lsl 6
let mod5Mask = 1 lsl 7
let button1Mask = 1 lsl 8
let button2Mask = 1 lsl 9
let button3Mask = 1 lsl 10
let button4Mask = 1 lsl 11
let button5Mask = 1 lsl 12
let anyModifier = 1 lsl 15

(* The server's checks: bits outside the field's protocol set are a BadValue *)
let check valid m = if m land lnot valid <> 0 then failwith "BadValue"

(* Grab modifiers and pointer event masks travel as CARD16: Xlib drops bits
   16-31 before the server sees them *)
let card16 m = m land 0xFFFF

(* SETofKEYMASK, or AnyModifier alone *)
let check_modifiers m =
  let m = card16 m in
  if m <> anyModifier then check 0xFF m
let grab_key modifiers = check_modifiers modifiers

let grab_button modifiers event_mask =
  check_modifiers modifiers;
  check 0x7FFC (card16 event_mask) (* SETofPOINTEREVENT *)

let ungrab_key modifiers = check_modifiers modifiers
let ungrab_button modifiers = check_modifiers modifiers
let all_events = check 0x1FFFFFF (* SETofEVENT *)
let pointer_events m = check 0x7FFC (card16 m) (* SETofPOINTEREVENT *)
let device_events = check 0x3F4F (* SETofDEVICEEVENT *)
let select_input = all_events
let grab_pointer = pointer_events
let change_active_pointer_grab = pointer_events
let change_do_not_propagate = device_events
let send_event = all_events

let create_window ?(event_mask = 0) ?(do_not_propagate_mask = 0) () =
  all_events event_mask;
  device_events do_not_propagate_mask

(* XCheckMaskEvent only reads Xlib's queue: the server never sees the mask *)
let check_mask_event _ = ()

(* Masks the server sends: the raw values, as C gets them *)
type keyEvent = { state : stateMask }
type buttonEvent = { state : stateMask }

let key_press state : keyEvent = { state }
let button_press state : buttonEvent = { state }
let query_pointer state = state

type windowAttributes = {
  all_event_masks : 'a. (([> eventFlags ] as 'a), union) mask;
  your_event_mask : 'a. (([> eventFlags ] as 'a), union) mask;
  do_not_propagate_mask : 'a. (([> deviceEventFlags ] as 'a), union) mask;
}

let window_attributes ~all ~yours ~dont_propagate =
  {
    all_event_masks = all;
    your_event_mask = yours;
    do_not_propagate_mask = dont_propagate;
  }
