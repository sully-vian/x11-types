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

## Questions for the user
