type (+'k, +'e, +'c) mask
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

type 'p keyMask = ('k, 'e, 'c) mask constraint 'p = ([> `Key ] as 'k) * 'e * 'c
(** The modifiers of a grab, [SETofKEYMASK or AnyModifier]. Annotate with
    [_ keyMask]: ['p] holds an open row and ['c], and both follow the value. *)

type stateMask = ([ `Key | `Button ], unit, union) mask
(** The state of an event: [SETofKEYBUTMASK], and the XKB group *)

type eventFlags = [ `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ]
type pointerEventFlags = [ `PointerEvent | `PointerDeviceEvent ]
type deviceEventFlags = [ `DeviceEvent | `PointerDeviceEvent ]

type 'a eventMask = ([ `Ev ], ([> eventFlags ] as 'a), union) mask
(** [SETofEVENT]. Annotate with [_ eventMask]: the row stays open, so the value
    can still take other flags. Likewise for the next two. *)

type 'a pointerEventMask = ([ `Ev ], ([> pointerEventFlags ] as 'a), union) mask
(** [SETofPOINTEREVENT] *)

type 'a deviceEventMask = ([ `Ev ], ([> deviceEventFlags ] as 'a), union) mask
(** [SETofDEVICEEVENT] *)

val ( ||| ) : ('k, 'e, union) mask -> ('k, 'f, union) mask -> ('k, 'g, 'c) mask
(** Union. [anyModifier] can't be an operand: [AnyModifier | ShiftMask] is a
    [BadValue]. *)

val ( &&& ) : ('k, 'e, 'c) mask -> ('k, 'f, 'd) mask -> bool
(** [m &&& flags]: [m] holds at least one of [flags], like C's [m & flags] *)

val ( &~ ) : ('k, 'e, 'c) mask -> ('k, 'f, 'd) mask -> ('k, 'e, 'c) mask
(** [m &~ flags]: [m] without [flags], like C's [m & ~flags]. It takes
    [anyModifier], since removing flags from it leaves it valid. *)

val ( &. ) :
  ([< `Key | `Button ], 'e, 'c) mask -> ([< `Key ], 'f, 'd) mask -> ([> `Key ], 'g, 'd) mask
(** [m &. modifiers]: the [modifiers] that [m] holds, like C's [m & modifiers].
    The result has no buttons or XKB group, so it fits a grab: it's how an
    event's state becomes one. It only holds bits of [modifiers], so it may be
    [anyModifier] only if they may. *)

(** {1 Event masks} *)

val noEventMask : ([> `Ev ], [< eventFlags ], 'c) mask
val keyPressMask : ([> `Ev ], [> `DeviceEvent ], 'c) mask
val keyReleaseMask : ([> `Ev ], [> `DeviceEvent ], 'c) mask
val buttonPressMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val buttonReleaseMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val enterWindowMask : ([> `Ev ], [> `PointerEvent ], 'c) mask
val leaveWindowMask : ([> `Ev ], [> `PointerEvent ], 'c) mask
val pointerMotionMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val pointerMotionHintMask : ([> `Ev ], [> `PointerEvent ], 'c) mask
val button1MotionMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val button2MotionMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val button3MotionMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val button4MotionMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val button5MotionMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val buttonMotionMask : ([> `Ev ], [> `PointerDeviceEvent ], 'c) mask
val keymapStateMask : ([> `Ev ], [> `PointerEvent ], 'c) mask
val exposureMask : ([> `Ev ], [> `Event ], 'c) mask
val visibilityChangeMask : ([> `Ev ], [> `Event ], 'c) mask
val structureNotifyMask : ([> `Ev ], [> `Event ], 'c) mask
val resizeRedirectMask : ([> `Ev ], [> `Event ], 'c) mask
val substructureNotifyMask : ([> `Ev ], [> `Event ], 'c) mask
val substructureRedirectMask : ([> `Ev ], [> `Event ], 'c) mask
val focusChangeMask : ([> `Ev ], [> `Event ], 'c) mask
val propertyChangeMask : ([> `Ev ], [> `Event ], 'c) mask
val colormapChangeMask : ([> `Ev ], [> `Event ], 'c) mask
val ownerGrabButtonMask : ([> `Ev ], [> `Event ], 'c) mask

(** {1 Key and button masks} *)

val noModifier : ([> `Key ], 'e, 'c) mask
(** No modifier: C writes 0 *)

val shiftMask : ([> `Key ], 'e, 'c) mask
val lockMask : ([> `Key ], 'e, 'c) mask
val controlMask : ([> `Key ], 'e, 'c) mask
val mod1Mask : ([> `Key ], 'e, 'c) mask
val mod2Mask : ([> `Key ], 'e, 'c) mask
val mod3Mask : ([> `Key ], 'e, 'c) mask
val mod4Mask : ([> `Key ], 'e, 'c) mask
val mod5Mask : ([> `Key ], 'e, 'c) mask
val button1Mask : ([> `Button ], 'e, 'c) mask
val button2Mask : ([> `Button ], 'e, 'c) mask
val button3Mask : ([> `Button ], 'e, 'c) mask
val button4Mask : ([> `Button ], 'e, 'c) mask
val button5Mask : ([> `Button ], 'e, 'c) mask
val anyModifier : ([> `Key ], 'e, alone) mask
(** Any combination of modifiers, including none: grabs only, and alone *)

(** {1 Stand-ins for the X calls}

    Each raises [Failure "BadValue"] when the server would. A call takes any
    subset of its field's flags, with or without [anyModifier]'s ['c]. *)

val grab_key : ([ `Key ], 'e, 'c) mask -> unit
(** XGrabKey's modifiers *)

val grab_button : ([ `Key ], 'e, 'c) mask -> ([ `Ev ], [< pointerEventFlags ], 'd) mask -> unit
(** XGrabButton's modifiers and event mask *)

val ungrab_key : ([ `Key ], 'e, 'c) mask -> unit
(** XUngrabKey's modifiers *)

val ungrab_button : ([ `Key ], 'e, 'c) mask -> unit
(** XUngrabButton's modifiers *)

val select_input : ([ `Ev ], [< eventFlags ], 'c) mask -> unit
val grab_pointer : ([ `Ev ], [< pointerEventFlags ], 'c) mask -> unit
val change_active_pointer_grab : ([ `Ev ], [< pointerEventFlags ], 'c) mask -> unit

val change_do_not_propagate : ([ `Ev ], [< deviceEventFlags ], 'c) mask -> unit
(** XChangeWindowAttributes' do_not_propagate_mask *)

val create_window :
  ?event_mask:([ `Ev ], [< eventFlags ], 'c) mask ->
  ?do_not_propagate_mask:([ `Ev ], [< deviceEventFlags ], 'd) mask ->
  unit ->
  unit
(** XCreateWindow's XSetWindowAttributes masks *)

val send_event : ([ `Ev ], [< eventFlags ], 'c) mask -> unit
(** XSendEvent's event_mask: the windows' selections the event goes to *)

val check_mask_event : ([ `Ev ], [< eventFlags ], 'c) mask -> unit
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
  all_event_masks : 'a. ([ `Ev ], ([> eventFlags ] as 'a), union) mask;
  your_event_mask : 'a. ([ `Ev ], ([> eventFlags ] as 'a), union) mask;
  do_not_propagate_mask : 'a. ([ `Ev ], ([> deviceEventFlags ] as 'a), union) mask;
}

val window_attributes :
  all:int -> yours:int -> dont_propagate:int -> windowAttributes
(** XGetWindowAttributes' masks *)
