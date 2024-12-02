#!/bin/bash
TOPLEVEL=$1

DATETIME=$(date --rfc-3339="seconds")

./build.sh
mkdir -p "waves"
cd work
ghdl -r -v --std=08 --workdir=work "$TOPLEVEL" --wave="../waves/$TOPLEVEL-$DATETIME.ghw"
cd ..
gtkwave "waves/$TOPLEVEL-$DATETIME.ghw" --rcvar 'do_initial_zoom_fit yes'
