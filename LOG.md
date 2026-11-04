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

## Questions for the user
