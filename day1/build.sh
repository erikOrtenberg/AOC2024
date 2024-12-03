#!/bin/bash

declare -a FILES=("buf" "buffer_tb" "mergesort")

for file in "${FILES[@]}"
do
  ghdl -a --std=08 --workdir=work "$file".vhd
  ghdl -e --std=08 --workdir=work -o work/"$file" "$file"
done
