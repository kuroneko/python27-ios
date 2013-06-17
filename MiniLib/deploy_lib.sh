#!/bin/bash
set -e

LIBROOT=$(dirname $0)
cd "$LIBROOT"

DESTROOT="$1"

if [ -z "$DESTROOT" ]; then
	echo "You must specify a destination for the library"
	exit 1
fi

# compile all of the code
python2.7 -m compileall -f .

# and deploy it into the destination
find . -name '*.pyo' -or -name '*.pyc' -print0 | xargs -0 -J '%' cp -rp % "$DESTROOT"