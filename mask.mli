(* Tags name the fields a mask fits; a second parameter for whether it can be or-ed *)

type (+'a, +'c) mask
type union
type alone

type keyMask = ([ `Grab ], alone) mask
type stateMask = ([ `State ], union) mask
type eventMask = ([ `Event ], union) mask
type pointerEventMask = ([ `Pointer ], union) mask
type deviceEventMask = ([ `Device ], union) mask

val ( ||| ) : ('a, union) mask -> ('a, union) mask -> ('a, 'c) mask

val ( &&& ) : ('a, 'c) mask -> ('a, 'c) mask -> bool
(** [m &&& flags]: [m] holds at least one of [flags], like C's [m & flags] *)

val ( &~ ) : ('a, 'c) mask -> ('a, 'c) mask -> ('a, 'c) mask
(** [m &~ flags]: [m] without [flags], like C's [m & ~flags] *)

val keys : ([< `Grab | `State ], 'c) mask -> ([< `Grab | `State ], 'd) mask
(** The modifiers of a mask, without its buttons and the XKB group *)

(** {1 Event masks} *)

val noEventMask : ([< `Event | `Pointer | `Device ], 'c) mask
val keyPressMask : ([< `Event | `Device ], 'c) mask
val keyReleaseMask : ([< `Event | `Device ], 'c) mask
val buttonPressMask : ([< `Event | `Pointer | `Device ], 'c) mask
val buttonReleaseMask : ([< `Event | `Pointer | `Device ], 'c) mask
val enterWindowMask : ([< `Event | `Pointer ], 'c) mask
val leaveWindowMask : ([< `Event | `Pointer ], 'c) mask
val pointerMotionMask : ([< `Event | `Pointer | `Device ], 'c) mask
val pointerMotionHintMask : ([< `Event | `Pointer ], 'c) mask
val button1MotionMask : ([< `Event | `Pointer | `Device ], 'c) mask
val button2MotionMask : ([< `Event | `Pointer | `Device ], 'c) mask
val button3MotionMask : ([< `Event | `Pointer | `Device ], 'c) mask
val button4MotionMask : ([< `Event | `Pointer | `Device ], 'c) mask
val button5MotionMask : ([< `Event | `Pointer | `Device ], 'c) mask
val buttonMotionMask : ([< `Event | `Pointer | `Device ], 'c) mask
val keymapStateMask : ([< `Event | `Pointer ], 'c) mask
val exposureMask : ([< `Event ], 'c) mask
val visibilityChangeMask : ([< `Event ], 'c) mask
val structureNotifyMask : ([< `Event ], 'c) mask
val resizeRedirectMask : ([< `Event ], 'c) mask
val substructureNotifyMask : ([< `Event ], 'c) mask
val substructureRedirectMask : ([< `Event ], 'c) mask
val focusChangeMask : ([< `Event ], 'c) mask
val propertyChangeMask : ([< `Event ], 'c) mask
val colormapChangeMask : ([< `Event ], 'c) mask
val ownerGrabButtonMask : ([< `Event ], 'c) mask

(** {1 Key and button masks} *)

val noModifier : ([< `Grab | `State ], 'c) mask
(** No modifier: C writes 0 *)

val shiftMask : ([< `Grab | `State ], 'c) mask
val lockMask : ([< `Grab | `State ], 'c) mask
val controlMask : ([< `Grab | `State ], 'c) mask
val mod1Mask : ([< `Grab | `State ], 'c) mask
val mod2Mask : ([< `Grab | `State ], 'c) mask
val mod3Mask : ([< `Grab | `State ], 'c) mask
val mod4Mask : ([< `Grab | `State ], 'c) mask
val mod5Mask : ([< `Grab | `State ], 'c) mask
val button1Mask : ([< `State ], 'c) mask
val button2Mask : ([< `State ], 'c) mask
val button3Mask : ([< `State ], 'c) mask
val button4Mask : ([< `State ], 'c) mask
val button5Mask : ([< `State ], 'c) mask
val anyModifier : ([< `Grab ], alone) mask

(** {1 Stand-ins for the X calls}

    Each raises [Failure "BadValue"] when the server would. *)

val grab_key : ([> `Grab ], 'c) mask -> unit
(** XGrabKey's modifiers *)

val grab_button : ([> `Grab ], 'c) mask -> ([> `Pointer ], 'c) mask -> unit
(** XGrabButton's modifiers and event mask *)

val ungrab_key : ([> `Grab ], 'c) mask -> unit
(** XUngrabKey's modifiers *)

val ungrab_button : ([> `Grab ], 'c) mask -> unit
(** XUngrabButton's modifiers *)

val select_input : ([> `Event ], 'c) mask -> unit
val grab_pointer : ([> `Pointer ], 'c) mask -> unit
val change_active_pointer_grab : ([> `Pointer ], 'c) mask -> unit

val change_do_not_propagate : ([> `Device ], 'c) mask -> unit
(** XChangeWindowAttributes' do_not_propagate_mask *)

val create_window :
  ?event_mask:([> `Event ], 'c) mask -> ?do_not_propagate_mask:([> `Device ], 'd) mask -> unit -> unit
(** XCreateWindow's XSetWindowAttributes masks *)

val send_event : ([> `Event ], 'c) mask -> unit
(** XSendEvent's event_mask: the windows' selections the event goes to *)

val check_mask_event : ([> `Event ], 'c) mask -> unit
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
