#!/usr/bin/env bash
# Usage: dune exec -- ./run.sh          scoreboard of mask.{mli,ml} against spec/
#        dune exec -- ./run.sh --spec   checks the spec against oracle/mask.ml, i.e. C
#        dune exec -- ./run.sh CASE     the full output of one case, e.g. valid/xkb_group
#
# The scoreboard: spec/valid cases must type-check, then run without an
# exception. spec/invalid and spec/misuse cases must be rejected by the type
# checker, and not because a name is unbound. Rejections show the first and
# last lines of the error, to check that they fail for the reason intended.
#
# The spec check: every case compiles against the oracle, where masks are ints
# and the X calls fail as the server does. valid and misuse cases must run
# without a BadValue, invalid ones must raise it.
set -u
root=$(cd "$(dirname "$0")" && pwd)
# dune exec runs _build/default's copy of this script, and doesn't refresh the
# copies next to it: read the source tree instead. Cram tests run in a sandbox
# of their own, holding their declared deps, and stay there.
root=${root%/_build/default}
mode=score
module=$root
case ${1:-} in
  --spec) mode=spec; module=$root/oracle ;;
  ?*) mode=one ;;
esac

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$module"/mask.ml "$work"
[ $mode = spec ] || cp "$module"/mask.mli "$work"
cd "$work"
if ! ocamlc -c $( [ $mode = spec ] || echo mask.mli ) mask.ml 2>err; then
  echo "mask doesn't compile:"; cat err; exit 1
fi

# A case's module name: valid/xkb_group is Valid_xkb_group, so that cases
# with the same name in two directories don't overwrite each other
modname() { echo "${1%%/*}_$(basename "$1")"; }

# Compiles spec case $1, and links it when $2 is "link"
compile() {
  local name
  name=$(modname "$1")
  cp "$root/spec/$1.ml" "$name.ml"
  if [ "$2" = link ]; then
    ocamlc mask.cmo "$name.ml" -o "$name.byte"
  else
    ocamlc -c -stop-after typing "$name.ml"
  fi
}
run() { ./"$(modname "$1")".byte; }

if [ $mode = one ]; then
  case $1 in valid/*) compile "$1" link && run "$1" ;; *) compile "$1" type ;; esac
  exit
fi

# The error in two lines: what was wrong, and why
reason() {
  local first last
  first=$(grep -m1 '^Error' "$1" | cut -c1-90)
  last=$(tail -n1 "$1" | sed 's/^ */       /' | cut -c1-90)
  echo "$first"
  [ "$last" = "       ${first#Error: }" ] || [ "$last" = "       $first" ] || echo "$last"
}

declare -A passed total
for kind in valid invalid misuse; do
  passed[$kind]=0; total[$kind]=0
  for f in "$root"/spec/$kind/*.ml; do
    case=$kind/$(basename "$f" .ml)
    total[$kind]=$((total[$kind] + 1))
    ok=false
    if [ $mode = spec ]; then
      if ! compile "$case" link >err 2>&1; then
        printf 'FAIL %s: not C\n' "$case"; reason err; continue
      fi
      run "$case" >err 2>&1
      grep -q BadValue err && got=invalid || got=valid
      [ "$(cat err)" = "" ] || [ $got = invalid ] || got="$(head -n1 err)"
      case $kind in invalid) [ "$got" = invalid ] ;; *) [ "$got" = valid ] ;; esac \
        && ok=true || printf 'FAIL %s: C gives %s\n' "$case" "$got"
    elif [ $kind = valid ]; then
      if ! compile "$case" link >err 2>&1; then
        printf 'FAIL %s: rejected\n' "$case"; reason err
      elif ! run "$case" >err 2>&1; then
        printf 'FAIL %s: %s\n' "$case" "$(head -n1 err)"
      else
        ok=true
      fi
    else
      if compile "$case" type >err 2>&1; then
        printf 'FAIL %s: accepted\n' "$case"
      elif grep -q '^Error: Unbound' err; then
        printf 'FAIL %s: rejected for a missing name\n' "$case"; reason err
      else
        printf 'pass %s\n' "$case"; reason err; ok=true
      fi
    fi
    if $ok; then
      passed[$kind]=$((passed[$kind] + 1))
      [ $mode = spec ] || [ $kind != valid ] || printf 'pass %s\n' "$case"
    fi
  done
done
echo
for kind in valid invalid misuse; do echo "$kind: ${passed[$kind]}/${total[$kind]}"; done
