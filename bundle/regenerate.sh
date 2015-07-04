#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")
ROOTDIR=$(dirname "$MYDIR")

target="$MYDIR/crumbr"
rm -f "$target" &&
mobundle                               \
   --head-from-paragraph               \
   --program "$ROOTDIR/script/crumbr"  \
   --output "$target"                  \
   --include "$ROOTDIR/lib"            \
   --modules-from "$MYDIR/modules.txt" &&
chmod +x "$target"
