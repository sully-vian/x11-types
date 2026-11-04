# Log

## Baseline: every mask an int

Score: valid 21/21, invalid 0/16, misuse 0/12. C's typing: everything
type-checks.

## Known before the first experiment

These come from the session that built the sandbox, measured on an earlier
version of the spec with two designs: x11's API at 323051c, and that API
plus a few changes x11 had planned. Check them again against the current
spec.

- x11's design: one polymorphic variant tag per group of flags the protocol
  treats alike (`` `Key ``, `` `Button ``, `` `Any ``, `` `Event ``,
  `` `PointerEvent ``, `` `DeviceEvent ``, `` `PointerDeviceEvent ``),
  `type 'a mask` abstract and invariant, constants open (`[> `Key ] mask`),
  field types closed (`keyMask = [ `Key | `Any ] mask`). It rejected most
  family mix-ups, but not `anyModifier ||| shiftMask`.
- Making `anyModifier : [ `Any ] mask` closed, with the grabs taking
  `[< `Key | `Any ] mask`, rejects `anyModifier ||| shiftMask`. But then a
  list holding both `anyModifier` and modifier sets no longer type-checks
  (`valid/binding_table`).
- `let m = buttonPressMask ||| pointerMotionMask`, passed to both
  `select_input` and `grab_pointer` (`valid/shared_event_mask`), failed with
  the invariant `'a mask`: the value restriction doesn't generalize `m`.
  Declaring `type +'a mask` (covariant) may fix it through the relaxed value
  restriction. Not tried yet.
- x11 planned `keys` with an open result (`[> `Key ] mask`), so that it can
  be compared with a binding and passed to `grab_key`. A closed result would
  also reject `keys state &&& button1Mask`, which is always false.

Ideas not tried: per-flag tags, a phantom parameter per family, private
types, a separate type for AnyModifier.

## Experiments

### 01: x11's design as it stands

Branch `exp/01-x11-tags`. One polymorphic variant tag per group of flags
(`` `Key ``, `` `Button ``, `` `Any ``, and the four event groups), `type 'a mask`
invariant, constants open, fields closed, plus `keys` with an open result. It
measures the starting point on the current spec.

Expected: every family mix-up rejected. Fails `valid/shared_event_mask` (value
restriction), and the three `*_any_modifier_union` cases.

Score: valid 20/21, invalid 13/16, misuse 12/12. As expected. Fails
`valid/shared_event_mask` (`m` stays weakly polymorphic, so `select_input` fixes
it to the whole of `eventMask`) and the three `*_any_modifier_union` cases. Not
merged: it fails a `valid` case that `main` passes, and fewer `valid` failures
beat more rejections.

Instrument note: `dune exec -- ./run.sh` runs `_build/default/run.sh` and only
builds that one file, so after an edit it scores a stale `mask.{mli,ml}`. The
first run here scored the int baseline. Run `dune build ./mask.ml ./mask.mli`
first. `dune test` isn't affected, its deps are declared.

### 02: covariant mask

Branch `exp/02-covariant`. Experiment 1 with `type +'a mask`, so that the relaxed
value restriction generalizes `let m = a ||| b`.

Expected: `valid/shared_event_mask` passes, so valid 21/21, and nothing else
moves (`invalid/shared_event_mask` still fails on the closed `pointerEventMask`).

Score: valid 21/21, invalid 13/16, misuse 12/12. Flipped
`valid/shared_event_mask` to pass, as expected. Merged: same valid as the
baseline, 25 more rejections. What's left is the three `*_any_modifier_union`.

### 03: AnyModifier closed

Branch `exp/03-closed-any`. Experiment 2 with `anyModifier : [ `Any ] mask` and
the grabs taking `[< `Key | `Any ] mask`, the idea recorded before the first
experiment, measured again on the current spec.

Expected: the three `*_any_modifier_union` cases pass, `valid/binding_table`
fails: valid 20/21, invalid 16/16, misuse 12/12.

Score: valid 20/21, invalid 16/16, misuse 12/12. Flipped the three
`*_any_modifier_union` to pass and `valid/binding_table` to fail, as expected.
Not merged: it trades a `valid` case for rejections.

**Result: no design with `( ||| ) : 'a mask -> 'a mask -> 'a mask` passes both
`valid/binding_table` and `invalid/grab_key_any_modifier_union`.** The table
puts `anyModifier`, `mod4Mask` and `mod4Mask ||| shiftMask` in one list, so
their types must unify. With one variable shared by the operands and the result,
unifying `anyModifier`'s type with the result is unifying it with the operands,
which is what typing `anyModifier ||| shiftMask` asks. So the operands of `|||`
and its result must have different types: a constant must fit both, and
`anyModifier` only the result. That needs a variable in the type of the
constants that the row of tags can't provide, because a row can't be extended
from a variable (no `[ 'a | `Any ]`). That is a second dimension, whichever way
it's written. It also rules out the idea "a separate type for AnyModifier": the
table needs one type for all its entries.

### 04: a second parameter, for what may be or-ed

Branch `exp/04-alone`. Following experiment 3's argument: `type (+'a, +'c) mask`,
where `'a` is experiment 2's tags and `'c` says whether the mask can be or-ed.
`( ||| )` takes two `('a, union) mask` and returns `('a, 'c) mask`, constants
are free in `'c`, and `anyModifier : ([> `Any ], alone) mask`. So a constant or
a union fits either, and `anyModifier` only fits `alone`. `keyMask` is
`([ `Key | `Any ], alone) mask`, the other field types are `union`. `&&&` and
`&~` don't look at `'c`, except that `&~` keeps its first operand's:
`anyModifier &~ m` is AnyModifier or 0, valid either way.

Expected: 21/21, 16/16, 12/12.

Score: valid 21/21, invalid 16/16, misuse 12/12. Flipped the three
`*_any_modifier_union` to pass, nothing else moved. Merged. Every rejection reads
as its case's comment says: `Type Mask.alone is not compatible with type
Mask.union` for AnyModifier in a union, a missing tag for the rest.

Programs outside the spec (the spec can't grow for now: see "Questions for the
user") show where it's still stricter than C:

- `grab_key (List.fold_left ( ||| ) noModifier [shiftMask; lockMask])`: the fold
  ties the accumulator to the operands, so its type is `union`, and `keyMask`
  wants `alone`. Rule 2 says accept. A real pattern for porting C loops.
- `select_input (p : pointerEventMask)` and `select_input
  attributes.do_not_propagate_mask`: subsets of SETofEVENT, refused because the
  fields are closed. Rule 2 says accept. `(p :> eventMask)` works thanks to
  covariance.
- `grab_key ((mod4Mask ||| button1Mask) &~ button1Mask)`,
  `grab_key (anyModifier ||| anyModifier)`, `grab_key (anyModifier ||| noModifier)`:
  see the summary, no design of this kind can take them.

### 05: no tag for AnyModifier

Branch `exp/05-no-any-tag`. `'c` already tells AnyModifier from the rest, so
`` `Any `` may be redundant: `anyModifier : ([> `Key ], alone) mask`, `keyMask =
([ `Key ], alone) mask`. To keep rejecting `ev.state &&& anyModifier`, `&&&` and
`&~` tie the `'c` of their operands.

Expected: no flip, one tag fewer. Merged if so, as a tie with simpler types.

Score: valid 21/21, invalid 16/16, misuse 12/12. No flip. Merged, a tie with
simpler types. The programs outside the spec answer as in experiment 4.

### 06: calls that take any subset of their field

Branch `exp/06-open-calls`. Calls stop naming the closed field types:
`select_input : ([< `Event | `PointerEvent | `DeviceEvent | `PointerDeviceEvent ],
'c) mask -> unit`, `grab_key : ([ `Key ], 'c) mask -> unit`. So a
`pointerEventMask` goes to `select_input` directly, and the `union` result of a
fold goes to `grab_key`.

Expected: no flip on the spec, and experiment 4's three rule 2 gaps (the fold and
the two narrower masks) close. The types are longer, so by the merge rule a tie
doesn't get it into `main` on its own.

Score: valid 21/21, invalid 16/16, misuse 12/12. No flip. The fold and both
narrower masks now type-check, and every program outside the spec that should be
rejected still is. Named row types keep the signatures short:
`select_input : ([< eventFlags ], 'c) mask -> unit`.

Not merged: it ties `main` with longer types, so the merge rule keeps
experiment 5. But it respects rule 2 on programs the spec has no case for: see
"Questions for the user".

### 07: tags name the fields, not the groups of flags

Branch `exp/07-field-tags`. Turning the rows around: a constant lists the fields
it is valid in, `keyPressMask : ([< `Event | `Device ], 'c) mask`, and a call
demands its own, `grab_pointer : ([> `Pointer ], 'c) mask`. A union intersects the
fields of its operands, and the group tags go: 5 tags instead of 6, one per
protocol set, and the constants read like the protocol's tables.

Expected: no flip. The error should read `does not allow tag(s) `Pointer`, naming
the field. Risk: `[`Device]` can't reach `[> `Event]`, so a narrower mask can't
go to `select_input`, even with a coercion.

Score: valid 21/21, invalid 16/16, misuse 12/12. No flip. The errors do name the
field (`does not allow tag(s) `Pointer`), though each constant's type is longer.
The risk was real, and it's a result: fields don't nest under this encoding, so
`select_input` can never take a `pointerEventMask`, and the `(p :> eventMask)`
that `main` allows is refused too (`no intersection`). Experiment 6 can't be
built on it. Not merged: one tag fewer doesn't make up for losing that, and x11's
tags are group tags, so it's further from what users have.

### 08: private int instead of abstract

Branch `exp/08-private`. `type (+'a, +'c) mask = private int`, from the list of
ideas not tried. A mask reads as an int with `(m :> int)`, as C code does, and an
int still can't become a mask.

Expected: no flip, since no case converts a mask to an int. Checks that the
phantom parameters still separate types through a private abbreviation.

Score: valid 21/21, invalid 16/16, misuse 12/12. No flip, `score.t` unchanged, and
the programs outside the spec answer as on `main`. The parameters still separate
types once they're declared covariant. Not merged: a tie, and not simpler. It
stays an option for the port if users need `(m :> int)`, without changing anything
else. Masks are already `int`s for the ctypes bindings, inside the library.

### 06, continued: grab_button's masks don't share `'c`

Same branch, after main's new cases were merged into it. The version first
recorded is 96d6022. The user found that its `grab_button` used one `'c` for both
masks, so `let events : pointerEventMask = ... in grab_button anyModifier events`
was refused, while `main` accepted it and so does C. That program is now
`valid/grab_button_any_modifier_events`. Reproduced on the branch: valid 24/25,
`Type Mask.union is not compatible with type Mask.alone`.

The idea: give the event mask its own variable, `'d`.

Expected: that case flips to pass, for 25/16/12.

Score: valid 25/25, invalid 16/16, misuse 12/12. Flipped
`valid/grab_button_any_modifier_events` to pass. Against `main`, it also flips
`valid/fold_modifiers`, `valid/pointer_mask_as_selection` and
`valid/device_mask_as_selection`. Merged: it now beats `main`'s 22/25 on the score.
`test/spec.t` didn't change on the branch beyond the totals it got from `main`.

## Questions for the user

1. **Merge `exp/06-open-calls`?** It ties `main` on the score with longer types,
   so the merge rule keeps it out, but it accepts programs that rule 2 says must
   type-check and that `main` refuses: `grab_key (List.fold_left ( ||| ) noModifier
   [...])` and `select_input (p : pointerEventMask)`. No spec case covers them.
   Recommendation: merge it. `git merge exp/06-open-calls` conflicts in `LOG.md` and
   in `mask.mli`, where `main` has since documented the types: keep `main`'s log and
   comments, and take the branch's signatures. No spec case flips on the branch, and
   the programs outside the spec that should be rejected still are.
2. **Can the spec grow?** `CLAUDE.md` allows adding cases, but says that
   `test/spec.t` must still pass and stay as recorded, and `spec.t` records the
   totals (`valid: 21/21`). So any new case breaks it. I added none, and kept the
   programs outside the spec in this log. With permission to update those totals,
   the fold and the narrower masks would become `valid` cases, and experiment 6
   would win on the score.
3. **Should rule 2 be read as "for the programs of the spec"?** As written it can't
   hold for any type system of this kind: see "What no design can do" below. Nothing
   here depends on the answer, but the README could say so.

## Summary

**The design** (`main`, from experiments 2, 4 and 5). `type (+'a, +'c) mask`, an
`int` at runtime. `'a` holds x11's group tags, without `` `Any ``: constants open
(`[> `Key ]`), fields closed. `'c` is `alone` for `anyModifier`, `union` for the
operands of `|||` and for the masks the server sends, and free in the constants
and in results of `|||`. Covariance makes `let m = a ||| b` polymorphic.

**The score:** valid 21/21, invalid 16/16, misuse 12/12. No case fails, and the
rejections read as their comments say. `test/spec.t`, `test/probe.t` and
`test/conform.t` are unchanged and pass.

**Why it takes two parameters:** experiment 3's argument. `valid/binding_table` and
`invalid/grab_key_any_modifier_union` can't both pass with one type variable
shared by the operands and the result of `|||`.

**Where it's stricter than C, outside the spec:**

- Closed by `exp/06-open-calls`, not merged (question 1): a fold's result to a
  grab, and a narrower mask to a wider field. On `main`, `(p :> eventMask)` is the
  workaround for the second.
- A `keyMask` value can't be or-ed even when it isn't AnyModifier at runtime:
  `{ m : keyMask }` then `b.m ||| lockMask`. The type admits AnyModifier, for which
  C gets a `BadValue`, so this one is rule 1's doing.

**What no design can do**, all C-valid and refused by every design tried:

- `anyModifier ||| anyModifier` and `anyModifier ||| noModifier`. `binding_table`
  makes `anyModifier`'s type unify with `shiftMask`'s. If `|||`'s operands can both
  be `anyModifier`'s type, then `anyModifier ||| shiftMask` type-checks too, unless
  a bound holds for each alone and not for their union, and a row bound can't say
  that (no "at most `` `A ``, or at most `` `B ``").
- `(mod4Mask ||| button1Mask) &~ button1Mask` to a grab. `&~` would have to remove a
  tag from a row, and OCaml has no row subtraction. Per-flag tags don't help.
- Anything that depends on a value: `grab_key (if n > 0 then shiftMask else
  button1Mask)` with `n` always positive. C decides at runtime what types must decide
  at compile time, so rule 2 only holds for programs whose masks don't depend on
  values.

**Ideas closed without a branch:**

- Per-flag tags: no case tells them from group tags, the field types would list up
  to 25 tags, and they don't help with `&~`.
- A phantom parameter per family: it says what the rows say, with one more parameter
  for each protocol set.
- A separate type for AnyModifier: refuted by experiment 3.

**What porting it changes for x11 users**, compared with `../x11/lib/x11.mli`:

- `'a mask` becomes `('a, 'c) mask`, so a written `[> `Key ] mask` needs its second
  parameter. The named types (`keyMask`, `eventMask`...) and the constants' names
  don't change, and code without annotations compiles as before.
- `anyModifier ||| m` and `m ||| anyModifier` become errors, and so does `|||` on a
  value typed `keyMask`. These were `BadValue`s at runtime, except for the second
  when the value isn't AnyModifier.
- `ev.state &&& anyModifier` becomes an error: it was always false.
- `let m = a ||| b` can now be used in several fields, with no annotation.
- `keys` and `noModifier` are new names, the way to turn a state into a grab.
- The `` `Any `` tag goes away, along with its row in `keyMask`.
- `lib/internal/mask.ml` declares the types, and the ctypes side keeps seeing `int`s.
