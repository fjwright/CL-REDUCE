#!/usr/bin/bash

# Check all CL REDUCE core test logs against the reference logs.

# Author: Francis J. Wright
# Based on code by Anthony C. Hearn.

# Assume this script is run in the top-level CL REDUCE directory.

rm -f log/checkcore.log

# sep is used in check-one-test.sh:
export sep
for (( i=80 ; i-- ; )); do sep=$sep+; done

packages="$(< fasl/core-packages.dat)"

for x in $packages
do
	echo $x
	./check-one-test.sh $x >> log/checkcore.log
done
