#!/usr/bin/bash

# Run all core test files in CL REDUCE and check the test logs against
# the reference logs.

# Author: Francis J. Wright
# Based on code by Anthony C. Hearn.

# Assume this script is run in the top-level CL REDUCE directory.

# Create log directory if necessary:
mkdir -p testlog

hostname > testlog/testcore.log
date >> testlog/testcore.log

rm -f testlog/checkcore.log

# sep is used in check-one-test.sh:
export sep
for (( i=80 ; i-- ; )); do sep=$sep+; done

packages="$(< fasl/core-packages.dat)"

for x in $packages
do
	echo +++++ Testing core package $x
	echo $x >> testlog/testcore.log
	./test-one-package.sh $x
done

date >> testlog/testcore.log
