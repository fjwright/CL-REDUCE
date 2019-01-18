#!/usr/bin/bash

# Check one CL REDUCE test log against the reference log.

# Author: Francis J. Wright
# Based (loosely) on code by Anthony C. Hearn.

# Usage: ./check-one-test.sh package

# Assume this script is run in the top-level CL REDUCE directory.

reflog=$(find -L packages -name $1.rlg)

if [ ! "$reflog" ]; then exit; fi

echo $'\nChecking' $1 $'...\n'

diff --strip-trailing-cr log/$1.rlg $reflog

if [ "$sep" ]; then echo -e '\f'; echo $sep; fi
