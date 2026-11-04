(* Tags for the flags a mask may hold; a second parameter for whether it can be or-ed *)

type (+'a, +'c) mask
type union
type alone

type keyMask = ([ `Key ], alone) mask
type stateMask = ([ `Key | `Button ], union) mask
type eventMask = ([ `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ], union) mask
type pointerEventMask = ([ `PointerEvent | `PointerDeviceEvent ], union) mask
type deviceEventMask = ([ `DeviceEvent | `PointerDeviceEvent ], union) mask

val ( ||| ) : ('a, union) mask -> ('a, union) mask -> ('a, 'c) mask

val ( &&& ) : ('a, 'c) mask -> ('a, 'c) mask -> bool
(** [m &&& flags]: [m] holds at least one of [flags], like C's [m & flags] *)

val ( &~ ) : ('a, 'c) mask -> ('a, 'c) mask -> ('a, 'c) mask
(** [m &~ flags]: [m] without [flags], like C's [m & ~flags] *)

val keys : ([< `Key | `Button ], 'c) mask -> ([> `Key ], 'd) mask
(** The modifiers of a mask, without its buttons and the XKB group *)

(** {1 Event masks} *)

val noEventMask : ([< `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ], 'c) mask
val keyPressMask : ([> `DeviceEvent ], 'c) mask
val keyReleaseMask : ([> `DeviceEvent ], 'c) mask
val buttonPressMask : ([> `PointerDeviceEvent ], 'c) mask
val buttonReleaseMask : ([> `PointerDeviceEvent ], 'c) mask
val enterWindowMask : ([> `PointerEvent ], 'c) mask
val leaveWindowMask : ([> `PointerEvent ], 'c) mask
val pointerMotionMask : ([> `PointerDeviceEvent ], 'c) mask
val pointerMotionHintMask : ([> `PointerEvent ], 'c) mask
val button1MotionMask : ([> `PointerDeviceEvent ], 'c) mask
val button2MotionMask : ([> `PointerDeviceEvent ], 'c) mask
val button3MotionMask : ([> `PointerDeviceEvent ], 'c) mask
val button4MotionMask : ([> `PointerDeviceEvent ], 'c) mask
val button5MotionMask : ([> `PointerDeviceEvent ], 'c) mask
val buttonMotionMask : ([> `PointerDeviceEvent ], 'c) mask
val keymapStateMask : ([> `PointerEvent ], 'c) mask
val exposureMask : ([> `Event ], 'c) mask
val visibilityChangeMask : ([> `Event ], 'c) mask
val structureNotifyMask : ([> `Event ], 'c) mask
val resizeRedirectMask : ([> `Event ], 'c) mask
val substructureNotifyMask : ([> `Event ], 'c) mask
val substructureRedirectMask : ([> `Event ], 'c) mask
val focusChangeMask : ([> `Event ], 'c) mask
val propertyChangeMask : ([> `Event ], 'c) mask
val colormapChangeMask : ([> `Event ], 'c) mask
val ownerGrabButtonMask : ([> `Event ], 'c) mask

(** {1 Key and button masks} *)

val noModifier : ([> `Key ], 'c) mask
(** No modifier: C writes 0 *)

val shiftMask : ([> `Key ], 'c) mask
val lockMask : ([> `Key ], 'c) mask
val controlMask : ([> `Key ], 'c) mask
val mod1Mask : ([> `Key ], 'c) mask
val mod2Mask : ([> `Key ], 'c) mask
val mod3Mask : ([> `Key ], 'c) mask
val mod4Mask : ([> `Key ], 'c) mask
val mod5Mask : ([> `Key ], 'c) mask
val button1Mask : ([> `Button ], 'c) mask
val button2Mask : ([> `Button ], 'c) mask
val button3Mask : ([> `Button ], 'c) mask
val button4Mask : ([> `Button ], 'c) mask
val button5Mask : ([> `Button ], 'c) mask
val anyModifier : ([> `Key ], alone) mask

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
