#!/usr/bin/env bash
# Usage: probe/run.sh   builds probe.c and runs it against its own Xvfb
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
cc -Wall -o "$tmp/probe" "$here/probe.c" -lX11
# Xvfb picks a free display and writes its number once it accepts connections
Xvfb -displayfd 1 -nolisten tcp >"$tmp/display" 2>/dev/null &
pid=$!
trap 'kill $pid 2>/dev/null; wait $pid 2>/dev/null; rm -rf "$tmp"' EXIT
until [ -s "$tmp/display" ]; do
  kill -0 $pid 2>/dev/null || { echo "Xvfb exited" >&2; exit 1; }
  sleep 0.05
done
DISPLAY=:$(cat "$tmp/display") "$tmp/probe"
