#!/bin/bash

# Run all core and/or noncore test files in CL REDUCE and check each
# test log against CSL.

# Author: Francis J. Wright
# Based on code by Anthony C. Hearn.

# Assume this script is run in the top-level CL REDUCE directory.

# Usage: ./test-packages.sh -l sbcl/clisp [-c] core &/or noncore

# Option -c ensures a clean test by deleting the testlog directory.
# The parameters core &/or noncore default to both if not specified.

if getopts l: option; then lisp=$OPTARG; (( n+=2 )); fi

if [ "$lisp" != 'sbcl' ] && [ "$lisp" != 'clisp' ]; then
    echo 'Error: option -l sbcl/clisp is required'
    exit
fi

if getopts c option; then rm -rf testlog.$lisp; (( n+=1 )); fi

shift $n

# Use the distributed test files for all tests:
case $OSTYPE in
    cygwin) export reduce='D:/Program Files/Reduce';;
    linux-gnu) export reduce='/usr/share/reduce';;
    *) echo "Unknown OSTYPE $OSTYPE; test aborted."; exit 1;;
esac

# Create log directory if necessary:
mkdir -p testlog.$lisp

# The variable sep is used in test-one-package.sh:
export sep
for (( i=80 ; i-- ; )); do sep=$sep+; done

whichdefault='core noncore'

echo 'Packages to test:' ${*:-$whichdefault}

for which in ${*:-$whichdefault}
do
    time {
        rm -f testlog.$lisp/check$which.log
        packages="$(< fasl.$lisp/$which-packages.dat)"
        for x in $packages
        do
            case $x in reduce4 | ibalp | gnuplot | turtle | rubi_red ) continue;; esac
            echo +++++ Testing $which package $x
            ./test-one-package.sh -l $lisp $x >> testlog.$lisp/check$which.log
        done
    }
done
