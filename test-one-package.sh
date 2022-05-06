#!/bin/bash

# Run one test file in CL REDUCE and check its test log against CSL.

# Author: Francis J. Wright
# Based (loosely) on code by Anthony C. Hearn.

# Usage: ./test-one-package.sh -l sbcl/clisp package

# Assume this script is run in the top-level CL REDUCE directory.
# This script is normally run by test-packages.sh.

if getopts l: option; then lisp=$OPTARG; shift 2; fi

if [ "$lisp" = 'sbcl' ]; then
    runreduce='sbcl --noinform --core fasl.sbcl/reduce.img --disable-ldb --lose-on-corruption'
elif [ "$lisp" = 'clisp' ]; then
    runreduce='clisp -M fasl.clisp/reduce.mem'
else
    echo 'Error: option -l sbcl/clisp is required'
    exit
fi

if [ ! -v reduce ]; then
    if [ -e './packages' ]; then export reduce=.
    elif [ -e '../packages' ]; then export reduce=..
    else echo 'Error: cannot find packages directory.  Please set $reduce.'; exit
    fi
fi

# Create log directory if necessary:
mkdir -p testlog.$lisp

testfile=$reduce/packages/$1/$1.tst # most likely location
if [ ! -e "$testfile" ]
then
    # Find the .red file, which must exist, then stop looking:
    testfile=$(find -L "$reduce/packages" -name $1.red -print -and -quit)
    # Change the filename to .tst:
    testfile=${testfile%%.red}.tst
fi

if [ ! -e "$testfile" ]; then exit; fi

$runreduce << EOF &> /dev/null # testlog.$lisp/$1-errors.rlg #
symbolic begin
  on errcont;   % So that computation continues after an error.
  off redefmsg;
  linelength 80;
  if '$1 eq 'rlisp88 then !*float!-print!-precision!* := 6;
  !*_xxx_!* := time(); !*_yyy_!* := gctime();
end;

out "testlog.$lisp/$1.rlg";

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

shut "testlog.$lisp/$1.rlg";

bye;
EOF

# Check for errors:

grep --max-count=10 --color=always --ignore-case '^[^%"]*\(\*\{5\} \| \<error\>\)\|COMMON-LISP:ERROR' testlog.$lisp/$1.rlg | uniq > /dev/tty

# Check for differences from CSL:

echo $'\nChecking' $1 $'...\n'
case $1 in
    # Special case until distribution snapshot is updated:
    rataprx) diff --strip-trailing-cr testlog.$lisp/$1.rlg ${testfile%%.tst}.rlg;;
    *) diff --strip-trailing-cr testlog.$lisp/$1.rlg testlog.csl/$1.rlg;;
esac
if [ "$sep" ]; then echo -e '\f'; echo $sep; fi
