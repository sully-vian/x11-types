#!/usr/bin/env bash
# Usage: reference/update.sh   downloads the sources and regenerates the
# excerpts. Versions are pinned here; X.h, Xproto.h and Xlib.h are read
# from the system (xorgproto, libx11).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
src=$(mktemp -d)
trap 'rm -rf "$src"' EXIT
cd "$src"
# gitlab.freedesktop.org's raw URLs redirect to a login page: use its API
gitlab() { # project path ref file
  curl -fsSL -o "$4" "https://gitlab.freedesktop.org/api/v4/projects/${1//\//%2F}/repository/files/${2//\//%2F}/raw?ref=$3"
}
xlibre=https://raw.githubusercontent.com/X11Libre/xserver/xlibre-xserver-25.1.9
curl -fsSL -o xlibre-events.c $xlibre/dix/events.c
curl -fsSL -o xlibre-exevents.c $xlibre/Xi/exevents.c
for f in GrKey.c GrButton.c GrPointer.c SelInput.c ChWAttrs.c; do
  gitlab xorg/lib/libx11 src/$f libX11-1.8.14 $f
done
for f in sect1-9.xml encoding.xml; do
  gitlab xorg/proto/xorgproto specs/xproto/$f 6d3907b6d5dc4aa7d7ee6ee5d7d8714e7466630b $f
done
python3 "$here/tools/protocol.py" "$here"
python3 "$here/tools/sources.py" "$here"
python3 "$here/tools/xlib_masks.py" "$here"
