type (+'a, +'c) mask
(** A set of X flags. An [int] at runtime.

    ['a] lists the groups of flags it may hold. The protocol gives each field
    its set of valid bits, and a tag stands for flags that all these sets allow
    or refuse together: a constant has an open type, as
    [shiftMask : ([> `Key ], 'c) mask], and a field a closed one.

    ['c] says whether it can be or-ed. Only [anyModifier] can't, as the server
    only accepts it alone. A constant fits either, so that a table of bindings
    can hold [anyModifier] and modifier sets side by side. *)

type union
(** ['c] of the masks known not to be [anyModifier] *)

type alone
(** ['c] of the masks that may be [anyModifier] *)

type keyMask = ([ `Key ], alone) mask
(** Modifiers that may be [anyModifier]: [SETofKEYMASK or AnyModifier]. The type
    of a table of bindings. *)

type stateMask = ([ `Key | `Button ], union) mask
(** The state of an event: [SETofKEYBUTMASK], and the XKB group *)

type eventFlags = [ `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ]
type pointerEventFlags = [ `PointerEvent | `PointerDeviceEvent ]
type deviceEventFlags = [ `DeviceEvent | `PointerDeviceEvent ]

type eventMask = (eventFlags, union) mask
(** [SETofEVENT] *)

type pointerEventMask = (pointerEventFlags, union) mask
(** [SETofPOINTEREVENT] *)

type deviceEventMask = (deviceEventFlags, union) mask
(** [SETofDEVICEEVENT] *)

val ( ||| ) : ('a, union) mask -> ('a, union) mask -> ('a, 'c) mask
(** Union. [anyModifier] can't be an operand: [AnyModifier | ShiftMask] is a
    [BadValue]. *)

val ( &&& ) : ('a, 'c) mask -> ('a, 'c) mask -> bool
(** [m &&& flags]: [m] holds at least one of [flags], like C's [m & flags] *)

val ( &~ ) : ('a, 'c) mask -> ('a, 'c) mask -> ('a, 'c) mask
(** [m &~ flags]: [m] without [flags], like C's [m & ~flags]. It takes
    [anyModifier], since removing flags from it leaves it valid. *)

val keys : ([< `Key | `Button ], 'c) mask -> ([> `Key ], 'd) mask
(** The modifiers of a mask, without its buttons and the XKB group. The result
    fits a grab: it's how an event's state becomes one. *)

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
(** Any combination of modifiers, including none: grabs only, and alone *)

(** {1 Stand-ins for the X calls}

    Each raises [Failure "BadValue"] when the server would. A call takes any
    subset of its field's flags, with or without [anyModifier]'s ['c]. *)

val grab_key : ([ `Key ], 'c) mask -> unit
(** XGrabKey's modifiers *)

val grab_button : ([ `Key ], 'c) mask -> ([< pointerEventFlags ], 'd) mask -> unit
(** XGrabButton's modifiers and event mask *)

val ungrab_key : ([ `Key ], 'c) mask -> unit
(** XUngrabKey's modifiers *)

val ungrab_button : ([ `Key ], 'c) mask -> unit
(** XUngrabButton's modifiers *)

val select_input : ([< eventFlags ], 'c) mask -> unit
val grab_pointer : ([< pointerEventFlags ], 'c) mask -> unit
val change_active_pointer_grab : ([< pointerEventFlags ], 'c) mask -> unit

val change_do_not_propagate : ([< deviceEventFlags ], 'c) mask -> unit
(** XChangeWindowAttributes' do_not_propagate_mask *)

val create_window :
  ?event_mask:([< eventFlags ], 'c) mask ->
  ?do_not_propagate_mask:([< deviceEventFlags ], 'd) mask ->
  unit ->
  unit
(** XCreateWindow's XSetWindowAttributes masks *)

val send_event : ([< eventFlags ], 'c) mask -> unit
(** XSendEvent's event_mask: the windows' selections the event goes to *)

val check_mask_event : ([< eventFlags ], 'c) mask -> unit
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
