#!/bin/bash -eu

for w in {1..8}
do
   for q in {1..5000..500}
   do
      ./obj/main $q $1 $w
   done
done
