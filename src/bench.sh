#!/bin/bash -eu

for w in $(seq 1 $3)
do
   ./obj/main $2 $1 $w
done
