"""Index of the Xlib functions and structure fields that take or return a mask.

Finds every prototype parameter of Xlib.h named like a mask, and classifies it
with the tables below. A mask parameter missing from the tables is an error,
so a new Xlib can't add one silently. Usage: xlib_masks.py OUTPUT_DIR
"""

import re
import sys

XLIB_H = '/usr/include/X11/Xlib.h'
src = open(XLIB_H).read()


def line_of(pos):
    return src.count('\n', 0, pos) + 1


# The masks this sandbox types: (function, parameter) -> (request, set, stand-in)
IN_SCOPE = {
    ('XGrabKey', 'modifiers'):
        ('GrabKey', 'SETofKEYMASK or AnyModifier, CARD16', 'grab_key'),
    ('XUngrabKey', 'modifiers'):
        ('UngrabKey', 'SETofKEYMASK or AnyModifier, CARD16', 'ungrab_key'),
    ('XGrabButton', 'modifiers'):
        ('GrabButton', 'SETofKEYMASK or AnyModifier, CARD16', 'grab_button'),
    ('XGrabButton', 'event_mask'):
        ('GrabButton', 'SETofPOINTEREVENT, CARD16', 'grab_button'),
    ('XUngrabButton', 'modifiers'):
        ('UngrabButton', 'SETofKEYMASK or AnyModifier, CARD16',
         'ungrab_button'),
    ('XGrabPointer', 'event_mask'):
        ('GrabPointer', 'SETofPOINTEREVENT, CARD16', 'grab_pointer'),
    ('XChangeActivePointerGrab', 'event_mask'):
        ('ChangeActivePointerGrab', 'SETofPOINTEREVENT, CARD16',
         'change_active_pointer_grab'),
    ('XSelectInput', 'event_mask'):
        ('ChangeWindowAttributes', 'SETofEVENT, CARD32', 'select_input'),
    ('XSendEvent', 'event_mask'):
        ('SendEvent', 'SETofEVENT, CARD32', 'send_event'),
    ('XQueryPointer', 'mask_return'):
        ('QueryPointer reply', 'SETofKEYBUTMASK, returned', 'query_pointer'),
    # Xlib's own event queue: no request, so no BadValue whatever the mask
    ('XMaskEvent', 'event_mask'): ('none (event queue)', 'SETofEVENT', ''),
    ('XWindowEvent', 'event_mask'): ('none (event queue)', 'SETofEVENT', ''),
    ('XCheckMaskEvent', 'event_mask'):
        ('none (event queue)', 'SETofEVENT', 'check_mask_event'),
    ('XCheckWindowEvent', 'event_mask'):
        ('none (event queue)', 'SETofEVENT', ''),
}

# Masks of other kinds, left out: (function, parameter) -> what they are
OUT_OF_SCOPE = {
    ('XCreateWindow', 'valuemask'): 'CW* value mask, of XSetWindowAttributes',
    ('XChangeWindowAttributes', 'valuemask'):
        'CW* value mask, of XSetWindowAttributes',
    ('XConfigureWindow', 'value_mask'):
        'CW* value mask, of XWindowChanges (x11: windowChanges)',
    ('XReconfigureWMWindow', 'mask'): 'CW* value mask, of XWindowChanges',
    ('XCreateGC', 'valuemask'): 'GC* value mask, of XGCValues',
    ('XChangeGC', 'valuemask'): 'GC* value mask, of XGCValues',
    ('XCopyGC', 'valuemask'): 'GC* value mask, of XGCValues',
    ('XGetGCValues', 'valuemask'): 'GC* value mask, of XGCValues',
    ('XChangeKeyboardControl', 'value_mask'):
        'KB* value mask, of XKeyboardControl',
    ('XGetImage', 'plane_mask'): 'plane mask: bits of a pixel',
    ('XGetSubImage', 'plane_mask'): 'plane mask: bits of a pixel',
    ('XSetPlaneMask', 'plane_mask'): 'plane mask: bits of a pixel',
    ('XSetState', 'plane_mask'): 'plane mask: bits of a pixel',
    ('XAllocColorCells', 'plane_masks_return'): 'plane masks: bits of a pixel',
    ('XAllocColorPlanes', 'rmask_return'): 'color plane mask',
    ('XAllocColorPlanes', 'gmask_return'): 'color plane mask',
    ('XAllocColorPlanes', 'bmask_return'): 'color plane mask',
    ('XCreatePixmapCursor', 'mask'): 'a Pixmap, the cursor\'s shape',
    ('XCreateGlyphCursor', 'mask_font'): 'a Font, the cursor\'s shape',
    ('XCreateGlyphCursor', 'mask_char'): 'a glyph, the cursor\'s shape',
    ('XListHosts', 'state_return'): 'a Bool',
}

# Structure fields: (struct, field) -> (requests, set, stand-in)
FIELDS = {
    ('XSetWindowAttributes', 'event_mask'):
        ('CreateWindow, ChangeWindowAttributes', 'SETofEVENT, CARD32',
         'create_window, select_input'),
    ('XSetWindowAttributes', 'do_not_propagate_mask'):
        ('CreateWindow, ChangeWindowAttributes', 'SETofDEVICEEVENT, CARD32',
         'create_window, change_do_not_propagate'),
    ('XWindowAttributes', 'all_event_masks'):
        ('GetWindowAttributes reply', 'SETofEVENT, returned',
         'window_attributes'),
    ('XWindowAttributes', 'your_event_mask'):
        ('GetWindowAttributes reply', 'SETofEVENT, returned',
         'window_attributes'),
    ('XWindowAttributes', 'do_not_propagate_mask'):
        ('GetWindowAttributes reply', 'SETofDEVICEEVENT, CARD16, returned',
         'window_attributes'),
    ('Screen', 'root_input_mask'):
        ('connection setup', 'SETofEVENT, returned', ''),
    ('XKeyEvent', 'state'):
        ('KeyPress, KeyRelease', 'SETofKEYBUTMASK + XKB group, returned',
         'key_press'),
    ('XButtonEvent', 'state'):
        ('ButtonPress, ButtonRelease', 'SETofKEYBUTMASK + XKB group, returned',
         'button_press'),
    ('XMotionEvent', 'state'):
        ('MotionNotify', 'SETofKEYBUTMASK + XKB group, returned', ''),
    ('XCrossingEvent', 'state'):
        ('EnterNotify, LeaveNotify', 'SETofKEYBUTMASK + XKB group, returned',
         ''),
}

proto = re.compile(r'extern\s+[\w\s*]+?\b(X\w+)\s*\(\s*(.*?)\);', re.S)
param = re.compile(r'([^,]*?)\s*/\*\s*(\w+)\s*\*/')
found = []
for m in proto.finditer(src):
    name = m.group(1)
    for p in param.finditer(m.group(2)):
        ctype, pname = p.group(1).strip(), p.group(2)
        if re.search(r'mask|modifiers|state', pname, re.I):
            found.append((name, pname, ctype, line_of(m.start(2) + p.start(2))))

unknown = [(f, p) for f, p, _, _ in found
           if (f, p) not in IN_SCOPE and (f, p) not in OUT_OF_SCOPE]
missing = [k for k in list(IN_SCOPE) + list(OUT_OF_SCOPE)
           if k not in {(f, p) for f, p, _, _ in found}]
if unknown or missing:
    sys.exit(f'unclassified: {unknown}\nnot in Xlib.h: {missing}')


def field_line(struct, field):
    """The line of [field] in the typedef of [struct], and its C type"""
    end = re.search(r'\}\s*' + struct + r'\s*;', src)
    start = src.rfind('typedef struct', 0, end.start())
    m = re.search(r'\n\s*([\w ]+?)\s+' + field + r'\s*;', src[start:end.start()])
    return line_of(start + m.start(1)), m.group(1)


def table(header, rows):
    widths = [max(len(r[i]) for r in [header] + rows) for i in range(len(header))]
    fmt = lambda r: '  '.join(c.ljust(w) for c, w in zip(r, widths)).rstrip()
    return '\n'.join([fmt(header), fmt(['-' * w for w in widths])]
                     + [fmt(r) for r in rows])


out = ['''Xlib functions and structure fields that take or return a mask.

Source: X11/Xlib.h from libX11 1.8.14, as installed in /usr/include. The
line numbers are its own. Generated by tools/xlib_masks.py, which fails if
Xlib.h has a mask parameter its tables don't classify.

"request" is what Xlib sends, to look up in protocol.txt and server.c.
"stand-in" is the function of mask.mli that models it, if any. Masks marked
"returned" come from the server, so no call of the program can get a BadValue
for them: they only matter for what a program can do with them.

Event and modifier masks: what the sandbox types
================================================
''']
rows = []
for f, p, ctype, line in found:
    if (f, p) in IN_SCOPE:
        request, kind, stand_in = IN_SCOPE[(f, p)]
        rows.append([f'{f} {p}', ctype, request, kind, stand_in or '-', str(line)])
out.append(table(['function, parameter', 'C type', 'request', 'set',
                  'stand-in', 'Xlib.h'], rows))
out.append('''
Structure fields
================
''')
rows = []
for (struct, field), (requests, kind, stand_in) in FIELDS.items():
    line, ctype = field_line(struct, field)
    rows.append([f'{struct}.{field}', ctype, requests, kind, stand_in or '-',
                 str(line)])
out.append(table(['field', 'C type', 'requests', 'set', 'stand-in', 'Xlib.h'],
                 rows))
out.append('''
Other masks, out of scope
=========================

Value masks say which fields of a structure are set: x11 hides them behind
records of options (windowChanges). Plane and color masks are bits of a pixel.
''')
rows = [[f'{f} {p}', ctype, OUT_OF_SCOPE[(f, p)], str(line)]
        for f, p, ctype, line in found if (f, p) in OUT_OF_SCOPE]
out.append(table(['function, parameter', 'C type', 'what it is', 'Xlib.h'],
                 rows))
open(sys.argv[1] + '/xlib-masks.txt', 'w').write('\n'.join(out) + '\n')
