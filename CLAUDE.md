# x11-types

You are designing the types of x11's masks: `mask.mli` and `mask.ml`. Read
`README.md` first: it holds the rules the design must respect, the contract
of `mask.mli`, and the loop. `reference/README.md` explains the X facts behind
the spec. `LOG.md` is what earlier sessions tried: read it before starting
anything, so that no idea is tried twice.

## The goal

Every case of `spec/valid` type-checks and runs, and every case of
`spec/invalid` and `spec/misuse` is rejected for the reason its comment gives.
The score is in `test/score.t`. Designs are ranked first by `valid`, then by
refusals (`invalid` + `misuse`): a valid C case refused is worse than a compiled
`BadValue`, and a user should never need `:>`. One exception: the refusal of
`valid/function_argument_shared` is accepted, because correcting it would lose the
distinction between event families in all `|||`. Between designs with the same
score, prefer the one with simpler types and clearer errors: the users are people
porting C code.

## What you may change

- `mask.mli` and `mask.ml`, freely.
- `spec/`: add cases, never move or delete one. A new case says where it comes
  from, and `test/spec.t` must still pass. If a case looks wrong, don't touch
  it: write why in `LOG.md` under "Questions for the user".
- `test/score.t`, through `dune promote`, after reading the diff.
- `test/spec.t`'s totals, the same way, when you add cases.
- `LOG.md`.

Everything else is the measuring instrument: `oracle/`, `probe/`, `run.sh`,
`reference/`, and the other tests. `test/probe.t` and `test/conform.t` must stay
as recorded. `test/spec.t` may change in its totals when cases are added, never
with a `FAIL` line. `dune promote` promotes every test, so check that the diff
holds nothing else before running it.

## How to work

- One idea per experiment, each on its own branch, `exp/NN-name`, started
  from `main`. Before writing code, add its entry to `LOG.md`: the idea, the
  branch, and what it should change in the score.
- Afterwards, record the score (valid, invalid, misuse) and the cases that
  flipped, both in `LOG.md` and in `test/score.t` on the branch.
- When an idea can't work, write why in the log. An argument that no design
  can satisfy two cases at once is a result, worth as much as a score.
- When a choice belongs to the user, such as giving up a rule, changing the
  contract or editing a case, write it under "Questions for the user" and go
  on with other ideas.

## Git

Use git fully: everything is allowed, commits, branches, merges, rebases,
tags, worktrees.

- `main` holds the best design so far. Merge an experiment into it when it
  beats `main`'s score, or ties it with simpler types. `LOG.md` is kept on
  `main` too: merge or cherry-pick each experiment's log entry, kept or not.
- Never delete a branch, even a dropped experiment: `git diff main exp/...`
  and `git show exp/...:mask.mli` are how a later session compares designs.
- Commit often, one step per commit, with messages like `type: description`
  (`feat: tag AnyModifier on its own`, `docs: log experiment 3`).
- Worktrees (`git worktree add ../x11-types-NN exp/NN-name`) let two variants
  build side by side, for example to compare their errors on the same case.
  Each has its own `_build`.

## Commands

```sh
dune exec -- ./run.sh                  # scoreboard of mask.{mli,ml}, in the source tree
dune exec -- ./run.sh invalid/NAME     # the compiler's full output for a case
dune test                              # score diff, plus the three checks
dune promote                           # records the score (read the diff first)
```

OCaml 5.5.1 comes from `dune.lock`: run the compiler through `dune exec`.
`test/probe.t` needs Xvfb and a C compiler.

## The end

`mask.mli` and `mask.ml` hold the best design, and `LOG.md` ends with a summary:
the design, its score, every case it still fails and why, and what porting it
to x11 would change for users (compared with `../x11/lib/x11.mli`).
