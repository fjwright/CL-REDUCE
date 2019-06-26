#!/bin/bash

# Run one test file in CSL REDUCE.

# Author: Francis J. Wright
# Based (loosely) on code by Anthony C. Hearn.

# Usage: ./csl-test-one-package.sh package

# Assume this script is run in the top-level CL REDUCE directory.
# This script is normally run by csl-test-packages.sh.

if [ ! -v reduce ]; then
    if [ -e './packages' ]; then export reduce=.
    elif [ -e '../packages' ]; then export reduce=..
    else echo 'Error: cannot find packages directory.  Please set $reduce.'; exit
    fi
fi

# Create log directory if necessary:
mkdir -p csltestlog

testfile=$reduce/packages/$1/$1.tst # most likely location
if [ ! -e "$testfile" ]
then
	# Find the .red file, which must exist, then stop looking:
	testfile=$(find -L "$reduce/packages" -name $1.red -print -and -quit)
	# Change the filename to .tst:
	testfile=${testfile%%.red}.tst
fi

if [ ! -e "$testfile" ]; then exit; fi

redcsl --nogui << EOF &> /dev/null
symbolic begin
  on errcont;   % So that computation continues after an error.
  linelength 80;
  !*_xxx_!* := time(); !*_yyy_!* := gctime();
end;

out "csltestlog/$1.rlg";

load_package $1;

in "$testfile";

symbolic begin
   % The use of difference in the following is required to finesse Orthovec's
   % renaming of -.
   terpri(); terpri(); prin2 "Time for test: ";
   prin2 difference(time(), !*_xxx_!*); prin2 " ms";
   if (!*_yyy_!* := difference(gctime(), !*_yyy_!*)) > 0 then
      <<prin2 ", plus GC time: "; prin2 !*_yyy_!*; prin2 " ms">>;
   terpri();
end;

shut "csltestlog/$1.rlg";

bye;
EOF
