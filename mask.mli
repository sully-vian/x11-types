(* The starting point: every mask is an int, as in C. All of spec/valid
   type-checks, and none of spec/invalid or spec/misuse is rejected. *)

type keyMask = int
type stateMask = int
type eventMask = int
type pointerEventMask = int
type deviceEventMask = int

val ( ||| ) : int -> int -> int

val ( &&& ) : int -> int -> bool
(** [m &&& flags]: [m] holds at least one of [flags], like C's [m & flags] *)

val ( &~ ) : int -> int -> int
(** [m &~ flags]: [m] without [flags], like C's [m & ~flags] *)

val keys : int -> int
(** The modifiers of a mask, without its buttons and the XKB group *)

(** {1 Event masks} *)

val noEventMask : int
val keyPressMask : int
val keyReleaseMask : int
val buttonPressMask : int
val buttonReleaseMask : int
val enterWindowMask : int
val leaveWindowMask : int
val pointerMotionMask : int
val pointerMotionHintMask : int
val button1MotionMask : int
val button2MotionMask : int
val button3MotionMask : int
val button4MotionMask : int
val button5MotionMask : int
val buttonMotionMask : int
val keymapStateMask : int
val exposureMask : int
val visibilityChangeMask : int
val structureNotifyMask : int
val resizeRedirectMask : int
val substructureNotifyMask : int
val substructureRedirectMask : int
val focusChangeMask : int
val propertyChangeMask : int
val colormapChangeMask : int
val ownerGrabButtonMask : int

(** {1 Key and button masks} *)

val noModifier : int
(** No modifier: C writes 0 *)

val shiftMask : int
val lockMask : int
val controlMask : int
val mod1Mask : int
val mod2Mask : int
val mod3Mask : int
val mod4Mask : int
val mod5Mask : int
val button1Mask : int
val button2Mask : int
val button3Mask : int
val button4Mask : int
val button5Mask : int
val anyModifier : int

(** {1 Stand-ins for the X calls}

    Each raises [Failure "BadValue"] when the server would. *)

val grab_key : keyMask -> unit
(** XGrabKey's modifiers *)

val grab_button : keyMask -> pointerEventMask -> unit
(** XGrabButton's modifiers and event mask *)

val ungrab_key : keyMask -> unit
(** XUngrabKey's modifiers *)

val ungrab_button : keyMask -> unit
(** XUngrabButton's modifiers *)

val select_input : eventMask -> unit
val grab_pointer : pointerEventMask -> unit
val change_active_pointer_grab : pointerEventMask -> unit

val change_do_not_propagate : deviceEventMask -> unit
(** XChangeWindowAttributes' do_not_propagate_mask *)

val create_window :
  ?event_mask:eventMask -> ?do_not_propagate_mask:deviceEventMask -> unit -> unit
(** XCreateWindow's XSetWindowAttributes masks *)

val send_event : eventMask -> unit
(** XSendEvent's event_mask: the windows' selections the event goes to *)

val check_mask_event : eventMask -> unit
(** XCheckMaskEvent: reads Xlib's queue, so it never gets a BadValue *)

(** {1 Masks the server sends}

    Each takes the raw value the server would send. *)

type keyEvent = { state : stateMask }

val key_press : int -> keyEvent
(** Bits 13 and 14 of [state] hold the XKB group when a second layout is
    active *)

type buttonEvent = { state : stateMask }

val button_press : int -> buttonEvent

val query_pointer : int -> stateMask
(** XQueryPointer's mask_return *)

type windowAttributes = {
  all_event_masks : eventMask;
  your_event_mask : eventMask;
  do_not_propagate_mask : deviceEventMask;
}

val window_attributes :
  all:int -> yours:int -> dont_propagate:int -> windowAttributes
(** XGetWindowAttributes' masks *)
