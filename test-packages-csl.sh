#!/bin/bash

# Run all core and/or noncore test files in CSL REDUCE.

# Author: Francis J. Wright
# Based (loosely) on code by Anthony C. Hearn.

# Usage: ./test-packages-csl.sh

# Assume this script is run in the top-level CL REDUCE directory.

if [ ! -v reduce ]; then
    if [ -e './packages' ]; then export reduce=.
    elif [ -e '../packages' ]; then export reduce=..
    else echo 'Error: cannot find packages directory.  Please set $reduce.'; exit
    fi
fi

# Create log directory if necessary:
mkdir -p testlog.csl

# Create .dat files that list core and non-core modules to build:
redcsl --nogui << EOF &> /dev/null
symbolic begin
  scalar w, i, s, core, noncore;
  i := open("$reduce/packages/package.map", 'input);
  s := rds i;
  w := read();
  rds s;
  close i;
  for each x in w do
     if member('csl, x) and member('psl, x) then <<
        if member('core, x) then core := x . core
        else noncore := x . noncore >>;
  i := open("testlog.csl/core-packages.dat", 'output);
  s := wrs i;
  for each x in reverse core do print car x;
  wrs s;
  close i;
  i := open("testlog.csl/noncore-packages.dat", 'output);
  s := wrs i;
  for each x in reverse noncore do print car x;
  wrs s;
  close i;
end;
bye;
EOF

# Allow for CRLF line endings:
IFS=$IFS$'\r'

for which in core noncore
do
    time {
	    packages="$(< testlog.csl/$which-packages.dat)"
	    for x in $packages
	    do
            case $x in reduce4 | ibalp | gnuplot | turtle | rubi_red ) continue;; esac
		    echo +++++ Testing $which package $x
		    ./test-one-package-csl.sh $x
	    done
    }
done
