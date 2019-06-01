#!/usr/bin/bash

# Run all core and/or noncore test files in CSL REDUCE.

# Author: Francis J. Wright
# Based on code by Anthony C. Hearn.

# Assume this script is run in the top-level CL REDUCE directory.

# Create log directory if necessary:
mkdir -p csltestlog

for which in core noncore
do
	hostname > csltestlog/test$which.log
	date >> csltestlog/test$which.log

	packages="$(< fasl/$which-packages.dat)"

	for x in $packages
	do
        case $x in reduce4 | gnuplot | turtle | rubi_red | lalr ) continue;; esac
		echo +++++ Testing $which package $x
		echo $x >> csltestlog/test$which.log
		./csl-test-one-package.sh $x
	done

	date >> csltestlog/test$which.log
done
