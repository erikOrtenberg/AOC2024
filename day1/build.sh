#!/bin/bash

declare -a FILES=("buf" "buffer_tb")

for file in "${FILES[@]}"
do
  ghdl -a --workdir=work "$file".vhd
  ghdl -e --workdir=work -o work/"$file" "$file"
done
