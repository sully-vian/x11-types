/* Xlib's side: how the C functions encode their mask arguments.

   Source: libX11 1.8.14 (https://gitlab.freedesktop.org/xorg/lib/libx11,
   tag libX11-1.8.14) and the request structures of Xproto.h, from xorgproto
   2026.1 as installed in /usr/include/X11. Xlib checks none of these masks:
   it assigns them to the request's fields, which truncates the unsigned int
   to the field's width.
   Copyright the X Consortium, The Open Group and others: MIT/X11 licenses,
   see the source files. */

/* ---- src/GrKey.c, lines 32-55 ---- */
int
XGrabKey(
    register Display *dpy,
    int key,
    unsigned int modifiers,
    Window grab_window,
    Bool owner_events,
    int pointer_mode,
    int keyboard_mode)

{
    register xGrabKeyReq *req;
    LockDisplay(dpy);
    GetReq(GrabKey, req);
    req->ownerEvents = owner_events;
    req->grabWindow = grab_window;
    req->modifiers = modifiers;
    req->key = key;
    req->pointerMode = pointer_mode;
    req->keyboardMode = keyboard_mode;
    UnlockDisplay(dpy);
    SyncHandle();
    return 1;
}

/* ---- src/GrButton.c, lines 32-60 ---- */
int
XGrabButton(
    register Display *dpy,
    unsigned int button, /* CARD8 */
    unsigned int modifiers, /* CARD16 */
    Window grab_window,
    Bool owner_events,
    unsigned int event_mask, /* CARD16 */
    int pointer_mode,
    int keyboard_mode,
    Window confine_to,
    Cursor curs)
{
    register xGrabButtonReq *req;
    LockDisplay(dpy);
    GetReq(GrabButton, req);
    req->modifiers = modifiers;
    req->button = button;
    req->grabWindow = grab_window;
    req->ownerEvents = owner_events;
    req->eventMask = event_mask;
    req->pointerMode = pointer_mode;
    req->keyboardMode = keyboard_mode;
    req->confineTo = confine_to;
    req->cursor = curs;
    UnlockDisplay(dpy);
    SyncHandle();
    return 1;
}

/* ---- src/GrPointer.c, lines 32-64 ---- */
int XGrabPointer(
    register Display *dpy,
    Window grab_window,
    Bool owner_events,
    unsigned int event_mask, /* CARD16 */
    int pointer_mode,
    int keyboard_mode,
    Window confine_to,
    Cursor curs,
    Time time)
{
    xGrabPointerReply rep;
    register xGrabPointerReq *req;
    register int status;
    LockDisplay(dpy);
    GetReq(GrabPointer, req);
    req->grabWindow = grab_window;
    req->ownerEvents = owner_events;
    req->eventMask = event_mask;
    req->pointerMode = pointer_mode;
    req->keyboardMode = keyboard_mode;
    req->confineTo = confine_to;
    req->cursor = curs;
    req->time = time;

    /* if we ever return, suppress the error */
    if (_XReply (dpy, (xReply *) &rep, 0, xTrue) == 0)
	rep.status = GrabSuccess;
    status = rep.status;
    UnlockDisplay(dpy);
    SyncHandle();
    return (status);
}

/* ---- src/SelInput.c, lines 32-48 ---- */
int
XSelectInput (
    register Display *dpy,
    Window w,
    long mask)
{
    register xChangeWindowAttributesReq *req;

    LockDisplay(dpy);
    GetReqExtra (ChangeWindowAttributes, 4, req);
    req->window = w;
    req->valueMask = CWEventMask;
    OneDataCard32 (dpy, NEXTPTR(req,xChangeWindowAttributesReq), mask);
    UnlockDisplay(dpy);
    SyncHandle();
    return 1;
}

/* ---- src/ChWAttrs.c, lines 38-56 ---- */
int
XChangeWindowAttributes (
    register Display *dpy,
    Window w,
    unsigned long valuemask,
    XSetWindowAttributes *attributes)
{
    register xChangeWindowAttributesReq *req;

    LockDisplay(dpy);
    GetReq(ChangeWindowAttributes,req);
    req->window = w;
    valuemask &= AllMaskBits;
    if ((req->valueMask = valuemask))
        _XProcessWindowAttributes (dpy, req, valuemask, attributes);
    UnlockDisplay(dpy);
    SyncHandle();
    return 1;
}

/* ---- X11/Xproto.h, lines 1458-1468 ---- */
typedef struct {
    CARD8 reqType;
    BOOL ownerEvents;
    CARD16 length;
    Window grabWindow;
    CARD16 eventMask;
    BYTE pointerMode, keyboardMode;
    Window confineTo;
    Cursor cursor;
    Time time;
} xGrabPointerReq;

/* ---- X11/Xproto.h, lines 1470-1482 ---- */
typedef struct {
    CARD8 reqType;
    BOOL ownerEvents;
    CARD16 length;
    Window grabWindow;
    CARD16 eventMask;
    BYTE pointerMode, keyboardMode;
    Window confineTo;
    Cursor cursor;
    CARD8 button;
    BYTE pad;
    CARD16 modifiers;
} xGrabButtonReq;

/* ---- X11/Xproto.h, lines 1513-1522 ---- */
typedef struct {
    CARD8 reqType;
    BOOL ownerEvents;
    CARD16 length;
    Window grabWindow;
    CARD16 modifiers;
    CARD8 key;
    BYTE pointerMode, keyboardMode;
    BYTE pad1, pad2, pad3;
} xGrabKeyReq;

/* ---- X11/Xproto.h, lines 1493-1501 ---- */
typedef struct {
    CARD8 reqType;
    BYTE pad;
    CARD16 length;
    Cursor cursor;
    Time time;
    CARD16 eventMask;
    CARD16 pad2;
} xChangeActivePointerGrabReq;

/* ---- X11/Xproto.h, lines 1524-1531 ---- */
typedef struct {
    CARD8 reqType;
    CARD8 key;
    CARD16 length;
    Window grabWindow;
    CARD16 modifiers;
    CARD16 pad;
} xUngrabKeyReq;

/* ---- X11/Xproto.h, lines 1484-1491 ---- */
typedef struct {
    CARD8 reqType;
    CARD8 button;
    CARD16 length;
    Window grabWindow;
    CARD16 modifiers;
    CARD16 pad;
} xUngrabButtonReq;

/* ---- X11/Xproto.h, lines 1449-1456 ---- */
typedef struct {
    CARD8 reqType;
    BOOL propagate;
    CARD16 length;
    Window destination;
    CARD32 eventMask;
    xEvent event;
} xSendEventReq;

/* ---- X11/Xproto.h, lines 1335-1349 ---- */
typedef struct {
    CARD8 reqType;
    CARD8 depth;
    CARD16 length;
    Window wid, parent;
    INT16 x, y;
    CARD16 width, height, borderWidth;
#if defined(__cplusplus) || defined(c_plusplus)
    CARD16 c_class;
#else
    CARD16 class;
#endif
    VisualID visual;
    CARD32 mask;
} xCreateWindowReq;
