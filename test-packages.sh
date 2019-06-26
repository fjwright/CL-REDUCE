#!/bin/bash

# Run all core and/or noncore test files in CL REDUCE and check each
# test log against CSL.

# Author: Francis J. Wright
# Based on code by Anthony C. Hearn.

# Assume this script is run in the top-level CL REDUCE directory.

# Usage: ./test-packages.sh -l sbcl/clisp [-c] core &/or noncore

# Option -c ensures a clean test by deleting the testlog directory.
# The parameters core &/or noncore default to both if not specified.

while getopts l:c option
do
    if   [ $option = l ]; then lisp=$OPTARG; (( n+=2 ))
    elif [ $option = c ]; then rm -rf testlog; (( n+=1 ))
    fi
done

if [ "$lisp" != 'sbcl' ] && [ "$lisp" != 'clisp' ]; then
    echo 'Error: option -l sbcl/clisp is required'
    exit
fi

shift $n

if [ ! -v reduce ]; then
    if [ -e './packages' ]; then export reduce=.
    elif [ -e '../packages' ]; then export reduce=..
    else echo 'Error: cannot find packages directory.  Please set $reduce.'; exit
    fi
fi

# Create log directory if necessary:
mkdir -p testlog

# The variable sep is used in test-one-package.sh:
export sep
for (( i=80 ; i-- ; )); do sep=$sep+; done

whichdefault='core noncore'

echo 'Packages to test:' ${*:-$whichdefault}

for which in ${*:-$whichdefault}
do
    time {
        rm -f testlog/check$which.log
        packages="$(< fasl/$which-packages.dat)"
        for x in $packages
        do
            case $x in reduce4 | ibalp | gnuplot | turtle | rubi_red ) continue;; esac
            echo +++++ Testing $which package $x
            ./test-one-package.sh -l $lisp $x >> testlog/check$which.log
        done
    }
done
