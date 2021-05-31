#!/bin/bash -eu

for w in $(seq 1 $3)
do
   $4 $2 $1 $w
done
