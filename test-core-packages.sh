#!/usr/bin/bash

# Run all core test files in CL REDUCE and check the test logs against
# the reference logs.

# Author: Francis J. Wright
# Based on code by Anthony C. Hearn.

# Assume this script is run in the top-level CL REDUCE directory.

# Create log directory if necessary:
mkdir -p log

hostname > log/testcore.log
date >> log/testcore.log

rm -f log/checkcore.log

# sep is used in check-one-test.sh:
export sep
for (( i=80 ; i-- ; )); do sep=$sep+; done

packages="$(< fasl/core-packages.dat)"

for x in $packages
do
	echo $x
	echo $x >> log/testcore.log
	./test-one-package.sh $x
done

date >> log/testcore.log

echo 'Errors:'
cd log
grep '\*\*\*\*\*\|error[^.]' *.rlg
cd ..
