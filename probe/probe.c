/* Asks a real X server which mask bits each request accepts: every bit alone,
   and every modifier bit or-ed with AnyModifier. oracle/probe.ml prints the
   same report from oracle/mask.ml, and test/probe.t checks they agree.

   All 32 bits are probed, including those of fields that travel as CARD16
   (grab modifiers, pointer event masks): Xlib drops their bits 16-31, so C
   accepts them, and the oracle must too. */

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <stdio.h>

static Display *dpy;
static Window root, win;
static int error_code;

static int record(Display *d, XErrorEvent *e) {
  (void)d;
  /* The first error of a request is the one the server checks first */
  if (!error_code) error_code = e->error_code;
  return 0;
}

/* Sends the request, waits for the server's answer, and reports whether it
   was a BadValue. Any other error is printed, since the probe should only
   meet BadValue. */
typedef void (*request)(unsigned long mask);

static int bad_value(const char *name, request r, unsigned long mask) {
  error_code = 0;
  r(mask);
  XSync(dpy, False);
  if (error_code && error_code != BadValue)
    printf("%s 0x%lx: unexpected error %d\n", name, mask, error_code);
  return error_code == BadValue;
}

static void report(const char *name, request r, int bits, int any_modifier) {
  unsigned long alone = 0, with_any = 0;
  for (int b = 0; b < bits; b++) {
    if (!bad_value(name, r, 1UL << b)) alone |= 1UL << b;
    if (any_modifier && b != 15 && !bad_value(name, r, AnyModifier | 1UL << b))
      with_any |= 1UL << b;
  }
  printf("%s: alone 0x%lx", name, alone);
  if (any_modifier) printf(", with AnyModifier 0x%lx", with_any);
  printf("\n");
}

static KeyCode keycode;

static void grab_key(unsigned long modifiers) {
  XGrabKey(dpy, keycode, modifiers, root, False, GrabModeAsync, GrabModeAsync);
  XUngrabKey(dpy, keycode, modifiers, root);
}

static void grab_button_modifiers(unsigned long modifiers) {
  XGrabButton(dpy, Button1, modifiers, root, False, ButtonPressMask,
              GrabModeAsync, GrabModeAsync, None, None);
  XUngrabButton(dpy, Button1, modifiers, root);
}

static void grab_button_event_mask(unsigned long mask) {
  XGrabButton(dpy, Button1, 0, root, False, mask, GrabModeAsync, GrabModeAsync,
              None, None);
  XUngrabButton(dpy, Button1, 0, root);
}

static void select_input(unsigned long mask) {
  XSelectInput(dpy, win, mask);
  XSelectInput(dpy, win, NoEventMask);
}

static void grab_pointer(unsigned long mask) {
  XGrabPointer(dpy, root, False, mask, GrabModeAsync, GrabModeAsync, None,
               None, CurrentTime);
  XUngrabPointer(dpy, CurrentTime);
}

static void change_do_not_propagate(unsigned long mask) {
  XSetWindowAttributes attributes = {.do_not_propagate_mask = mask};
  XChangeWindowAttributes(dpy, win, CWDontPropagate, &attributes);
}

static void ungrab_key(unsigned long modifiers) {
  XUngrabKey(dpy, keycode, modifiers, root);
}

static void ungrab_button(unsigned long modifiers) {
  XUngrabButton(dpy, Button1, modifiers, root);
}

/* Needs an active grab to change */
static void change_active_pointer_grab(unsigned long mask) {
  XGrabPointer(dpy, root, False, ButtonPressMask, GrabModeAsync, GrabModeAsync,
               None, None, CurrentTime);
  XChangeActivePointerGrab(dpy, mask, None, CurrentTime);
  XUngrabPointer(dpy, CurrentTime);
}

static void send_event(unsigned long mask) {
  XEvent event = {.xclient = {.type = ClientMessage,
                              .window = win,
                              .message_type = XA_STRING,
                              .format = 32}};
  XSendEvent(dpy, win, False, mask, &event);
}

static Window create_window(unsigned long valuemask,
                            XSetWindowAttributes *attributes) {
  return XCreateWindow(dpy, root, 0, 0, 1, 1, 0, CopyFromParent, InputOutput,
                       CopyFromParent, valuemask, attributes);
}

static void create_window_event_mask(unsigned long mask) {
  XSetWindowAttributes attributes = {.event_mask = mask};
  XDestroyWindow(dpy, create_window(CWEventMask, &attributes));
}

static void create_window_do_not_propagate(unsigned long mask) {
  XSetWindowAttributes attributes = {.do_not_propagate_mask = mask};
  XDestroyWindow(dpy, create_window(CWDontPropagate, &attributes));
}

/* Xlib's queue only: no request, no error whatever the mask */
static void check_mask_event(unsigned long mask) {
  XEvent event;
  while (XCheckMaskEvent(dpy, mask, &event))
    ;
}

int main(void) {
  dpy = XOpenDisplay(NULL);
  if (!dpy) {
    fprintf(stderr, "can't open display\n");
    return 1;
  }
  XSetErrorHandler(record);
  root = DefaultRootWindow(dpy);
  win = XCreateSimpleWindow(dpy, root, 0, 0, 10, 10, 0, 0, 0);
  keycode = XKeysymToKeycode(dpy, XK_a);

  report("grab_key modifiers", grab_key, 32, 1);
  report("grab_button modifiers", grab_button_modifiers, 32, 1);
  report("grab_button event_mask", grab_button_event_mask, 32, 0);
  report("select_input", select_input, 32, 0);
  report("grab_pointer", grab_pointer, 32, 0);
  report("change_do_not_propagate", change_do_not_propagate, 32, 0);
  report("ungrab_key modifiers", ungrab_key, 32, 1);
  report("ungrab_button modifiers", ungrab_button, 32, 1);
  report("change_active_pointer_grab", change_active_pointer_grab, 32, 0);
  report("send_event", send_event, 32, 0);
  report("create_window event_mask", create_window_event_mask, 32, 0);
  report("create_window do_not_propagate_mask", create_window_do_not_propagate,
         32, 0);
  report("check_mask_event", check_mask_event, 32, 0);
  XCloseDisplay(dpy);
  return 0;
}
