/* The X server's checks on mask arguments: where each BadValue comes from.

   Source: XLibre xserver 25.1.9, the Xvfb probe/run.sh runs here
   (https://github.com/X11Libre/xserver, tag xlibre-xserver-25.1.9).
   Xorg's xserver 21.1.16 makes the same checks: the same excerpts taken from
   it differ only in line numbers and in two local variable declarations of
   EventSelectForWindow.
   Copyright the X Consortium, The Open Group and others: MIT/X11 licenses,
   see the source files. */

/* ---- dix/events.c, lines 168-186 ---- */
#define AllButtonsMask ( \
	Button1Mask | Button2Mask | Button3Mask | Button4Mask | Button5Mask )
#define MotionMask ( \
	PointerMotionMask | Button1MotionMask | \
	Button2MotionMask | Button3MotionMask | Button4MotionMask | \
	Button5MotionMask | ButtonMotionMask )
#define PropagateMask ( \
	KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask | \
	MotionMask )
#define PointerGrabMask ( \
	ButtonPressMask | ButtonReleaseMask | \
	EnterWindowMask | LeaveWindowMask | \
	PointerMotionHintMask | KeymapStateMask | \
	MotionMask )
#define AllModifiersMask ( \
	ShiftMask | LockMask | ControlMask | Mod1Mask | Mod2Mask | \
	Mod3Mask | Mod4Mask | Mod5Mask )
#define LastEventMask OwnerGrabButtonMask
#define AllEventMasks (LastEventMask|(LastEventMask-1))

/* XSelectInput is ChangeWindowAttributes with CWEventMask, which calls this */
/* ---- dix/events.c, lines 4542-4549 ---- */
XRetCode EventSelectForWindow(WindowPtr pWin, ClientPtr client, Mask mask)
{
    Mask check;
    int rc;

    if (mask & ~AllEventMasks) {
        client->errorValue = mask;
        return BadValue;
    }
    ...

/* The do-not-propagate-mask of ChangeWindowAttributes and CreateWindow */
/* ---- dix/events.c, lines 4611-4619 ---- */
int
EventSuppressForWindow(WindowPtr pWin, ClientPtr client,
                       Mask mask, Bool *checkOptional)
{
    int i, freed;

    if (mask & ~PropagateMask) {
        client->errorValue = mask;
        return BadValue;
    }
    ...

/* XGrabPointer. Only the low 16 bits arrive: xGrabPointerReq.eventMask is a CARD16 */
/* ---- dix/events.c, lines 5010-5011 ---- */
int
ProcGrabPointer(ClientPtr client)
    ...
/* ---- dix/events.c, lines 5033-5036 ---- */
    if (stuff->eventMask & ~PointerGrabMask) {
        client->errorValue = stuff->eventMask;
        return BadValue;
    }
    ...

/* ---- dix/events.c, lines 5073-5074 ---- */
int
ProcChangeActivePointerGrab(ClientPtr client)
    ...
/* ---- dix/events.c, lines 5084-5087 ---- */
    if (stuff->eventMask & ~PointerGrabMask) {
        client->errorValue = stuff->eventMask;
        return BadValue;
    }
    ...

/* XGrabKey: the modifiers are checked by CheckGrabValues */
/* ---- dix/events.c, lines 5648-5672 ---- */
int
ProcGrabKey(ClientPtr client)
{
    WindowPtr pWin;

    REQUEST(xGrabKeyReq);
    GrabPtr grab;
    DeviceIntPtr keybd = PickKeyboard(client);
    int rc;
    GrabParameters param;
    GrabMask mask;

    REQUEST_SIZE_MATCH(xGrabKeyReq);

    param = (GrabParameters) {
        .grabtype = CORE,
        .ownerEvents = stuff->ownerEvents,
        .this_device_mode = stuff->keyboardMode,
        .other_devices_mode = stuff->pointerMode,
        .modifiers = stuff->modifiers
    };

    rc = CheckGrabValues(client, &param);
    if (rc != Success)
        return rc;
    ...

/* XIAnyModifier is 1U << 31, out of reach of a core request's CARD16 */
/* ---- Xi/exevents.c, lines 2445-2479 ---- */
int
CheckGrabValues(ClientPtr client, GrabParameters *param)
{
    if (param->grabtype != CORE &&
        param->grabtype != XI && param->grabtype != XI2) {
        ErrorF("[Xi] grabtype is invalid. This is a bug.\n");
        return BadImplementation;
    }

    if ((param->this_device_mode != GrabModeSync) &&
        (param->this_device_mode != GrabModeAsync) &&
        (param->this_device_mode != XIGrabModeTouch)) {
        client->errorValue = param->this_device_mode;
        return BadValue;
    }
    if ((param->other_devices_mode != GrabModeSync) &&
        (param->other_devices_mode != GrabModeAsync) &&
        (param->other_devices_mode != XIGrabModeTouch)) {
        client->errorValue = param->other_devices_mode;
        return BadValue;
    }

    if (param->modifiers != AnyModifier &&
        param->modifiers != XIAnyModifier &&
        (param->modifiers & ~AllModifiersMask)) {
        client->errorValue = param->modifiers;
        return BadValue;
    }

    if ((param->ownerEvents != xFalse) && (param->ownerEvents != xTrue)) {
        client->errorValue = param->ownerEvents;
        return BadValue;
    }
    return Success;
}

/* XGrabButton: the modifiers checked as in CheckGrabValues, then the event mask */
/* ---- dix/events.c, lines 5699-5737 ---- */
int
ProcGrabButton(ClientPtr client)
{
    WindowPtr pWin, confineTo;

    REQUEST(xGrabButtonReq);
    CursorPtr cursor;
    GrabPtr grab;
    DeviceIntPtr ptr, modifierDevice;
    Mask access_mode = DixGrabAccess;
    GrabMask mask;
    GrabParameters param;
    int rc;

    REQUEST_SIZE_MATCH(xGrabButtonReq);
    UpdateCurrentTime();
    if ((stuff->pointerMode != GrabModeSync) &&
        (stuff->pointerMode != GrabModeAsync)) {
        client->errorValue = stuff->pointerMode;
        return BadValue;
    }
    if ((stuff->keyboardMode != GrabModeSync) &&
        (stuff->keyboardMode != GrabModeAsync)) {
        client->errorValue = stuff->keyboardMode;
        return BadValue;
    }
    if ((stuff->modifiers != AnyModifier) &&
        (stuff->modifiers & ~AllModifiersMask)) {
        client->errorValue = stuff->modifiers;
        return BadValue;
    }
    if ((stuff->ownerEvents != xFalse) && (stuff->ownerEvents != xTrue)) {
        client->errorValue = stuff->ownerEvents;
        return BadValue;
    }
    if (stuff->eventMask & ~PointerGrabMask) {
        client->errorValue = stuff->eventMask;
        return BadValue;
    }
    ...

/* XUngrabKey: the same modifiers check as the grabs */
/* ---- dix/events.c, lines 5594-5595 ---- */
int
ProcUngrabKey(ClientPtr client)
    ...
/* ---- dix/events.c, lines 5614-5619 ---- */
    if ((stuff->modifiers != AnyModifier) &&
        (stuff->modifiers & ~AllModifiersMask)) {
        client->errorValue = stuff->modifiers;
        return BadValue;
    }
    tempGrab = AllocGrab(NULL);
    ...

/* XUngrabButton: the same modifiers check as the grabs */
/* ---- dix/events.c, lines 5793-5794 ---- */
int
ProcUngrabButton(ClientPtr client)
    ...
/* ---- dix/events.c, lines 5804-5809 ---- */
    if ((stuff->modifiers != AnyModifier) &&
        (stuff->modifiers & ~AllModifiersMask)) {
        client->errorValue = stuff->modifiers;
        return BadValue;
    }
    rc = dixLookupWindow(&pWin, stuff->grabWindow, client, DixReadAccess);
    ...

/* XSendEvent: SETofEVENT, as XSelectInput. The checks before it are on
   the event itself */
/* ---- dix/events.c, lines 5487-5488 ---- */
int
ProcSendEvent(ClientPtr client)
    ...
/* ---- dix/events.c, lines 5532-5535 ---- */
    if (stuff->eventMask & ~AllEventMasks) {
        client->errorValue = stuff->eventMask;
        return BadValue;
    }
    ...

/* XCreateWindow goes through ChangeWindowAttributes too, so its masks get
   the checks of EventSelectForWindow and EventSuppressForWindow */
