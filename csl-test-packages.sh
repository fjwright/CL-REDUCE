#!/bin/bash

# Run all core and/or noncore test files in CSL REDUCE.

# Author: Francis J. Wright
# Based (loosely) on code by Anthony C. Hearn.

# Usage: ./csl-test-packages.sh

# Assume this script is run in the top-level CL REDUCE directory.

if [ ! -v reduce ]; then
    if [ -e './packages' ]; then export reduce=.
    elif [ -e '../packages' ]; then export reduce=..
    else echo 'Error: cannot find packages directory.  Please set $reduce.'; exit
    fi
fi

# Create log directory if necessary:
mkdir -p csltestlog

for which in core noncore
do
    time {
	    packages="$(< fasl/$which-packages.dat)"
	    for x in $packages
	    do
            case $x in reduce4 | ibalp | gnuplot | turtle | rubi_red ) continue;; esac
		    echo +++++ Testing $which package $x
		    ./csl-test-one-package.sh $x
	    done
    }
done
