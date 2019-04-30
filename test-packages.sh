#!/usr/bin/bash

# Run all core and/or noncore test files in CL REDUCE and check each
# test log against CSL.

# Author: Francis J. Wright
# Based on code by Anthony C. Hearn.

# Assume this script is run in the top-level CL REDUCE directory.

# Usage: ./test-packages.sh [-c] core &/or noncore

# The parameters default to 'core noncore' if not specified.

# Option -c ensures a clean test by deleting the testlog directory.
if getopts c option; then shift; rm -rf testlog; fi

# Create log directory if necessary:
mkdir -p testlog

# The variable sep is used in test-one-package.sh:
export sep
for (( i=80 ; i-- ; )); do sep=$sep+; done

whichdefault='core noncore'

echo 'Packages to test:' ${*:-$whichdefault}

for which in ${*:-$whichdefault}
do
    hostname > testlog/test$which.log
    date >> testlog/test$which.log

    rm -f testlog/check$which.log

    packages="$(< fasl/$which-packages.dat)"

    for x in $packages
    do
        # if [[ $x = pm || $x = gnuplot || $x = turtle || $x = rubi_red ]]
        # then continue; fi
        case $x in pm | gnuplot | turtle | rubi_red | lalr ) continue;; esac
        echo +++++ Testing $which package $x
        echo $x >> testlog/test$which.log
        ./test-one-package.sh $x >> testlog/check$which.log
    done

    date >> testlog/test$which.log
done
