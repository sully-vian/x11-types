(* x11's design: one tag per group of flags, invariant *)

type 'a mask

type keyMask = [ `Key | `Any ] mask
type stateMask = [ `Key | `Button ] mask
type eventMask = [ `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ] mask
type pointerEventMask = [ `PointerEvent | `PointerDeviceEvent ] mask
type deviceEventMask = [ `DeviceEvent | `PointerDeviceEvent ] mask

val ( ||| ) : 'a mask -> 'a mask -> 'a mask

val ( &&& ) : 'a mask -> 'a mask -> bool
(** [m &&& flags]: [m] holds at least one of [flags], like C's [m & flags] *)

val ( &~ ) : 'a mask -> 'a mask -> 'a mask
(** [m &~ flags]: [m] without [flags], like C's [m & ~flags] *)

val keys : [< `Key | `Button | `Any ] mask -> [> `Key ] mask
(** The modifiers of a mask, without its buttons and the XKB group *)

(** {1 Event masks} *)

val noEventMask : [< `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ] mask
val keyPressMask : [> `DeviceEvent ] mask
val keyReleaseMask : [> `DeviceEvent ] mask
val buttonPressMask : [> `PointerDeviceEvent ] mask
val buttonReleaseMask : [> `PointerDeviceEvent ] mask
val enterWindowMask : [> `PointerEvent ] mask
val leaveWindowMask : [> `PointerEvent ] mask
val pointerMotionMask : [> `PointerDeviceEvent ] mask
val pointerMotionHintMask : [> `PointerEvent ] mask
val button1MotionMask : [> `PointerDeviceEvent ] mask
val button2MotionMask : [> `PointerDeviceEvent ] mask
val button3MotionMask : [> `PointerDeviceEvent ] mask
val button4MotionMask : [> `PointerDeviceEvent ] mask
val button5MotionMask : [> `PointerDeviceEvent ] mask
val buttonMotionMask : [> `PointerDeviceEvent ] mask
val keymapStateMask : [> `PointerEvent ] mask
val exposureMask : [> `Event ] mask
val visibilityChangeMask : [> `Event ] mask
val structureNotifyMask : [> `Event ] mask
val resizeRedirectMask : [> `Event ] mask
val substructureNotifyMask : [> `Event ] mask
val substructureRedirectMask : [> `Event ] mask
val focusChangeMask : [> `Event ] mask
val propertyChangeMask : [> `Event ] mask
val colormapChangeMask : [> `Event ] mask
val ownerGrabButtonMask : [> `Event ] mask

(** {1 Key and button masks} *)

val noModifier : [> `Key ] mask
(** No modifier: C writes 0 *)

val shiftMask : [> `Key ] mask
val lockMask : [> `Key ] mask
val controlMask : [> `Key ] mask
val mod1Mask : [> `Key ] mask
val mod2Mask : [> `Key ] mask
val mod3Mask : [> `Key ] mask
val mod4Mask : [> `Key ] mask
val mod5Mask : [> `Key ] mask
val button1Mask : [> `Button ] mask
val button2Mask : [> `Button ] mask
val button3Mask : [> `Button ] mask
val button4Mask : [> `Button ] mask
val button5Mask : [> `Button ] mask
val anyModifier : [> `Any ] mask

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
