# Reference

Excerpts of the specs and sources that decide which masks get a `BadValue`,
for whoever iterates on `mask.mli`. They aren't the ground truth:
`probe/probe.c` asks a real server, and `test/probe.t` checks that the oracle
agrees with it. They explain why the sets look the way they do.

| File | From | What it answers |
|---|---|---|
| `protocol.txt` | X protocol spec (xorgproto) | What each set holds, its bits, and the requests that take it |
| `server.c` | XLibre xserver 25.1.9 (same checks as Xorg 21.1.16) | Where each `BadValue` is raised |
| `xlib.c` | libX11 1.8.14, `Xproto.h` | How Xlib encodes each mask, and the width of each field |
| `X.h` | xorgproto | The constants' values |
| `xlib-masks.txt` | libX11 1.8.14's `Xlib.h` | Every Xlib function and structure field that takes or returns a mask, with its request and set |

`update.sh` downloads the sources at pinned versions and regenerates every
file with the scripts in `tools/`.

## What they establish

The valid bits of each field, as the server checks them:

| Stand-in | Field | Set | Server check | Valid bits |
|---|---|---|---|---|
| `grab_key`, `grab_button`, `ungrab_key`, `ungrab_button` | modifiers (CARD16) | SETofKEYMASK or AnyModifier | `modifiers != AnyModifier && modifiers & ~AllModifiersMask` | `0xFF`, or `0x8000` alone |
| `grab_button`, `grab_pointer`, `change_active_pointer_grab` | event-mask (CARD16) | SETofPOINTEREVENT | `eventMask & ~PointerGrabMask` | `0x7FFC` |
| `select_input`, `create_window`, `send_event` | event-mask (CARD32) | SETofEVENT | `mask & ~AllEventMasks` | `0x1FFFFFF` |
| `change_do_not_propagate`, `create_window` | do-not-propagate-mask (CARD32) | SETofDEVICEEVENT | `mask & ~PropagateMask` | `0x3F4F` |
| `check_mask_event` | none: Xlib's queue | SETofEVENT | none | all |

What these tables don't show:

- **Xlib truncates the 16-bit fields.** `XGrabPointer`, `XGrabButton` and
  `XGrabKey` take an `unsigned int` and assign it to a CARD16 (libX11 even
  comments `/* CARD16 */`). Bits 16 to 31 never reach the server, so
  `XGrabPointer(..., StructureNotifyMask, ...)` gets no `BadValue`: the flag is
  silently dropped. That's why `spec/misuse/` holds those cases, not
  `spec/invalid/`.
- **AnyModifier only works alone.** The server compares the whole field with
  `AnyModifier` before checking the bits. `XIAnyModifier` (bit 31) is accepted
  by the same function, but a core request's CARD16 can't carry it.
- **Event states don't match their set.** The protocol marks `0xE000` of
  SETofKEYBUTMASK as "unused but must be zero", yet XKB puts the keyboard group
  in bits 13 and 14 of every event's `state` when a second layout is active
  (`spec/valid/xkb_group`).
- **The do-not-propagate mask has two widths.** It is 4 bytes in
  `CreateWindow`/`ChangeWindowAttributes` but 2 bytes in the
  `GetWindowAttributes` reply, where SETofDEVICEEVENT's bits all fit.
- **Some Xlib functions send no request.** `XMaskEvent`, `XWindowEvent`,
  `XCheckMaskEvent` and `XCheckWindowEvent` filter Xlib's own event queue, so
  no mask can get a `BadValue` there: only rule 3 constrains them.

## Not in the spec

From `xlib-masks.txt`, the masks without a stand-in of their own, each
because one already covers it:

- `XMaskEvent`, `XWindowEvent`, `XCheckWindowEvent`: Xlib's queue, as
  `check_mask_event`.
- `XChangeWindowAttributes`: its masks are `select_input`'s and
  `change_do_not_propagate`'s.
- The `state` of motion and crossing events: the same set as
  `button_press`'s.
- `Screen.root_input_mask`: a returned SETofEVENT, as in `window_attributes`.

A new stand-in starts with its request in `probe/probe.c` and
`oracle/probe.ml`, and its check in `oracle/mask.ml`, before any case uses it.
