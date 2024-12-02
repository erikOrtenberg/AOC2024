#!/bin/bash
TOPLEVEL=$1

DATETIME=$(date --rfc-3339="seconds")


./build.sh
mkdir -p "waves"
cd work
ghdl -r --workdir=work "$1" --wave="../waves/$TOPLEVEL-$DATETIME.ghw"
cd ..
gtkwave "waves/$TOPLEVEL-$DATETIME.ghw" 
