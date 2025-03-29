#! /bin/sh

set -e

this_dir="$(readlink -f "$(dirname "$0")")"

exec "$this_dir"/opt/storytailor/storytailor "$@"
