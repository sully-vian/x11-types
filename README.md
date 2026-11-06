# x11-types

A sandbox for the type design of [x11](../x11)'s masks. The goal is a
`mask.mli`/`mask.ml` pair (abstract mask types, the operations on masks, and
stand-ins for the X calls that take them, such as `grab_key`) that ports
back to x11 directly.

## The rules

1. If an OCaml call with mask arguments type-checks, its C equivalent doesn't
   get a `BadValue`.
2. If a C call gets no `BadValue` for any value its mask expressions can take,
   judging each mask by the constants it's built from, and a union containing
   AnyModifier counts as invalid, its OCaml equivalent type-checks.

Rule 2 doesn't count these as failures, though C accepts them:
`anyModifier ||| anyModifier`, `anyModifier ||| noModifier`, and
`(mod4Mask ||| button1Mask) &~ button1Mask` passed to a grab.

A third rule applies to cases that the first two can't decide. C sometimes
accepts a mask only because two constants share a value: `ShiftMask` and
`KeyPressMask` are both 1.

3. A constant only type-checks in the fields of its own protocol set.

## Layout

- `mask.mli`, `mask.ml`: the design being iterated on. It starts loose, with
  every mask an `int` as in C: all of `spec/valid` passes, and nothing that
  should be rejected is.
- `spec/valid/`: by rule 2, programs whose C equivalent gets no `BadValue`.
  They must type-check, then run without an exception. Some test calls alone;
  others port real code (sowm's `mod_clean`, binding tables, XKB group bits),
  since rule 2 applies to programs that build masks before passing them.
- `spec/invalid/`: by rule 1, programs whose C equivalent gets a `BadValue`.
  They must be rejected.
- `spec/misuse/`: by rule 3, programs C accepts only through a shared value.
  They must be rejected.
- `oracle/mask.ml`: C, frozen. Masks are ints, and each stand-in fails as the
  server does, Xlib's truncation of 16-bit fields included. It checks the spec
  itself, not the design.
- `probe/probe.c`: asks a real X server (its own Xvfb) which bits each request
  accepts. `oracle/probe.ml` prints the same report from a Mask module.
- `oracle/semantics.ml`: prints what a Mask module computes besides the calls:
  constants, operators, and the masks the server sends.
- `CLAUDE.md`, `LOG.md`: the instructions for a session iterating on the
  design, and its log. Each variant it tries is an `exp/` branch.
- `reference/`: excerpts of the protocol spec, the X server and Xlib, with
  the facts they establish. See `reference/README.md`.
- `test/score.t`: the recorded score of `mask.{mli,ml}`.
- `test/spec.t`: the check that every case is in the right directory.
- `test/probe.t`: the check that the oracle agrees with the server. It needs
  Xvfb, a C compiler and Xlib's headers.
- `test/conform.t`: the check that `mask.ml` computes what the oracle does,
  from `probe.ml` and `semantics.ml`. A design changes types, never values.

Each case starts with a comment saying where it comes from (sowm, tinywm, the
protocol) and, when rejected, why.

## The loop

```sh
dune exec -- ./run.sh                # scoreboard, from the source tree: no build first
dune exec -- ./run.sh valid/xkb_group  # the compiler's full output for one case
dune test                            # diffs the score and the three checks
dune promote                         # records them
```

A rejection only counts when it isn't an unbound name. Otherwise a missing
name would make a case pass by accident. The scoreboard prints the first and
last lines of each error, to check that cases fail for the reason intended and
that the errors stay readable.

## The contract

`mask.mli` provides the names below, and the spec only uses them. How each one
is typed is the design.

- Mask types: `stateMask`, and `keyMask`, `eventMask`, `pointerEventMask`,
  `deviceEventMask`, each taking one parameter: a case annotates with
  `_ keyMask`.
- Operators: `|||` (union), `&&&` (holds any of), `&~` (difference), and
  `&.` (intersection with modifiers: the result is a set of modifiers, without
  buttons and XKB group bits).
- Constants: X.h's event, modifier and button masks, `anyModifier`, and
  `noModifier` (C's 0 for modifiers).
- Calls, each modelling one Xlib function's masks: `grab_key`, `ungrab_key`,
  `grab_button` (modifiers, then event mask), `ungrab_button`, `grab_pointer`,
  `change_active_pointer_grab`, `select_input`, `change_do_not_propagate`,
  `create_window ?event_mask ?do_not_propagate_mask ()`, `send_event`,
  `check_mask_event`.
- Masks the server sends, built from a raw `int`: `key_press` and
  `button_press` (records with a `state` field), `query_pointer`, and
  `window_attributes ~all ~yours ~dont_propagate` (a record with the fields
  `all_event_masks`, `your_event_mask` and `do_not_propagate_mask`).
- Equality through OCaml's `=`.

Every mask is an `int` at runtime, so that the design ports back to x11's
ctypes bindings. `conform.t` relies on it.

## Rules for the spec

- Add a case or fix a wrong one, never move one to make the design pass.
  `test/spec.t` must stay at full marks.
- The oracle changes only when the probe says so. A new stand-in starts in
  `probe/probe.c`, `oracle/probe.ml` and `oracle/mask.ml`, with `probe.t`
  showing that the server agrees, before any case uses it.
- `test/probe.t` and `test/conform.t` must stay as recorded. `test/spec.t` may
  change in its totals when cases are added, never with a `FAIL` line.
  `test/score.t` moves freely.
