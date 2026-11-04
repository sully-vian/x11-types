import re, sys
def L(f): return open(f).read().split('\n')
def quote(f, a, b, label=None):
    ls = L(f)
    return f'/* ---- {label or f}, lines {a}-{b} ---- */\n' + '\n'.join(ls[a-1:b]) + '\n'
def find(f, pat, after=0):
    return next(i + 1 for i, l in enumerate(L(f)) if i + 1 > after and re.search(pat, l))
def block(f, start_pat, end_pat, label, after=0, pre=0):
    a = find(f, start_pat, after) - pre
    b = find(f, end_pat, a)
    return quote(f, a, b, label)

ev, ex = 'xlibre-events.c', 'xlibre-exevents.c'
evl, exl = 'dix/events.c', 'Xi/exevents.c'
parts = ['''/* The X server's checks on mask arguments: where each BadValue comes from.

   Source: XLibre xserver 25.1.9, the Xvfb probe/run.sh runs here
   (https://github.com/X11Libre/xserver, tag xlibre-xserver-25.1.9).
   Xorg's xserver 21.1.16 makes the same checks: the same excerpts taken from
   it differ only in line numbers and in two local variable declarations of
   EventSelectForWindow.
   Copyright the X Consortium, The Open Group and others: MIT/X11 licenses,
   see the source files. */
''']
parts.append(block(ev, r'define AllButtonsMask', r'define AllEventMasks', evl))
parts.append('/* XSelectInput is ChangeWindowAttributes with CWEventMask, which calls this */\n'
             + block(ev, r'^XRetCode EventSelectForWindow', r'return BadValue', evl, pre=0) + '    }\n    ...\n')
parts.append('/* The do-not-propagate-mask of ChangeWindowAttributes and CreateWindow */\n'
             + block(ev, r'^EventSuppressForWindow', r'return BadValue', evl, pre=1) + '    }\n    ...\n')
a = find(ev, r'^ProcGrabPointer'); 
parts.append('/* XGrabPointer. Only the low 16 bits arrive: xGrabPointerReq.eventMask is a CARD16 */\n'
             + quote(ev, a - 1, a, evl) + '    ...\n' + quote(ev, find(ev, r'eventMask & ~PointerGrabMask', a), find(ev, r'eventMask & ~PointerGrabMask', a) + 3, evl) + '    ...\n')
a = find(ev, r'^ProcChangeActivePointerGrab')
parts.append(quote(ev, a - 1, a, evl) + '    ...\n' + quote(ev, find(ev, r'eventMask & ~PointerGrabMask', a), find(ev, r'eventMask & ~PointerGrabMask', a) + 3, evl) + '    ...\n')
a = find(ev, r'^ProcGrabKey\(')
parts.append('/* XGrabKey: the modifiers are checked by CheckGrabValues */\n'
             + quote(ev, a - 1, find(ev, r'^    if \(rc != Success\)', a) + 1, evl) + '    ...\n')
parts.append('/* XIAnyModifier is 1U << 31, out of reach of a core request\'s CARD16 */\n'
             + block(ex, r'^CheckGrabValues', r'^}', exl, pre=1))
a = find(ev, r'^ProcGrabButton')
parts.append('/* XGrabButton: the modifiers checked as in CheckGrabValues, then the event mask */\n'
             + quote(ev, a - 1, find(ev, r'eventMask & ~PointerGrabMask', a) + 3, evl) + '    ...\n')
for name, pat in [('ProcUngrabKey', r'modifiers & ~AllModifiersMask'),
                  ('ProcUngrabButton', r'modifiers & ~AllModifiersMask')]:
    a = find(ev, '^' + name + r'\(')
    c = find(ev, pat, a)
    parts.append(f'/* X{name[4:]}: the same modifiers check as the grabs */\n'
                 + quote(ev, a - 1, a, evl) + '    ...\n'
                 + quote(ev, c - 1, c + 4, evl) + '    ...\n')
a = find(ev, r'^ProcSendEvent\(')
c = find(ev, r'eventMask & ~AllEventMasks', a)
parts.append('/* XSendEvent: SETofEVENT, as XSelectInput. The checks before it are on\n'
             '   the event itself */\n'
             + quote(ev, a - 1, a, evl) + '    ...\n' + quote(ev, c, c + 3, evl) + '    ...\n')
parts.append('/* XCreateWindow goes through ChangeWindowAttributes too, so its masks get\n'
             '   the checks of EventSelectForWindow and EventSuppressForWindow */\n')
open(sys.argv[1] + '/server.c', 'w').write('\n'.join(parts))

# Xlib
parts = ['''/* Xlib's side: how the C functions encode their mask arguments.

   Source: libX11 1.8.14 (https://gitlab.freedesktop.org/xorg/lib/libx11,
   tag libX11-1.8.14) and the request structures of Xproto.h, from xorgproto
   2026.1 as installed in /usr/include/X11. Xlib checks none of these masks:
   it assigns them to the request's fields, which truncates the unsigned int
   to the field's width.
   Copyright the X Consortium, The Open Group and others: MIT/X11 licenses,
   see the source files. */
''']
for f in ['GrKey.c', 'GrButton.c', 'GrPointer.c', 'SelInput.c']:
    a = find(f, r'^(int )?X[A-Z][A-Za-z]+\s*\(')
    if not L(f)[a-1].startswith('int'): a -= 1
    b = find(f, r'^}', a)
    parts.append(quote(f, a, b, f'src/{f}'))
cw = 'ChWAttrs.c'
parts.append(block(cw, r'^XChangeWindowAttributes', r'^}', 'src/ChWAttrs.c', pre=1))
xp = '/usr/include/X11/Xproto.h'
for s in ['xGrabPointerReq', 'xGrabButtonReq', 'xGrabKeyReq',
          'xChangeActivePointerGrabReq', 'xUngrabKeyReq', 'xUngrabButtonReq',
          'xSendEventReq', 'xCreateWindowReq']:
    b = find(xp, r'\} ' + s + ';')
    a = max(i for i in range(1, b) if re.match(r'typedef struct', L(xp)[i-1]))
    parts.append(quote(xp, a, b, 'X11/Xproto.h'))
open(sys.argv[1] + '/xlib.c', 'w').write('\n'.join(parts))

# X.h
xh = '/usr/include/X11/X.h'
parts = ['''/* The constants, from X.h (xorgproto 2026.1, as installed in /usr/include/X11).
   Copyright The Open Group: MIT/X11 license, see the file. */
''']
parts.append(block(xh, r'^#define NoEventMask', r'^#define OwnerGrabButtonMask', 'X11/X.h', pre=6))
parts.append(block(xh, r'^#define ShiftMask', r'^#define Mod5Mask', 'X11/X.h', pre=4))
parts.append(block(xh, r'^#define Button1Mask', r'^#define AnyModifier', 'X11/X.h', pre=4))
open(sys.argv[1] + '/X.h', 'w').write('\n'.join(parts))
