#!/bin/bash

declare -a FILES=("buf" "buffer_tb" "mergesort" "mergesort_tb" "abssub" "accumulator" "part1" "part1_tb" "systolic_array" "part2" "part2_tb")

for file in "${FILES[@]}"
do
  ghdl -a --std=08 --workdir=work "$file".vhd
  ghdl -e --std=08 --workdir=work -o work/"$file" "$file"
done
