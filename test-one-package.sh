#!/usr/bin/bash

# Run one test file in CL REDUCE and check its test log against the
# reference log.

# Author: Francis J. Wright
# Based (loosely) on code by Anthony C. Hearn.

# Usage: ./test-one-package.sh package

# Assume this script is run in the top-level CL REDUCE directory.
# This script is normally run by test-core/noncore-packages.sh.

# Create log directory if necessary:
mkdir -p log

testfile=packages/$1/$1.tst		# most likely location
if [ ! -e $testfile ]
then
	# Find the .red file, which must exist, then stop looking:
	testfile=$(find -L packages -name $1.red -print -and -quit)
	# Change the filename to .tst:
	testfile=${testfile%%.red}.tst
fi

if [ ! -e $testfile ]; then exit; fi

sbcl --noinform --core reduce.img << EOF &> /dev/null # log/$1-errors.rlg #
(start-reduce)

symbolic begin
  on errcont;   % So that computation continues after an error.
  linelength 80;
  !*_xxx_!* := time(); !*_yyy_!* := gctime();
end;

out "log/$1.rlg";

"$testfile";  % to facilitate interactively finding the .rlg file

load_package $1;

in "$testfile";

symbolic begin
  % The +- construct in the following is required to finesse Orthovec's
  % renaming of -.
  terpri(); terpri(); prin2 "Time for test: ";
  prin2 (time()+-!*_xxx_!*); prin2 " ms";
  if (!*_yyy_!* := gctime()+-!*_yyy_!*)>0 then
  <<prin2 ", plus GC time: "; prin2 !*_yyy_!*;
    prin2 " ms">>;
  terpri();
end;

shut "log/$1.rlg";

bye;
EOF

reflog=${testfile%%.tst}.rlg

( echo $'\nChecking' $1 $'...\n'
diff --strip-trailing-cr log/$1.rlg $reflog
if [ "$sep" ]; then echo -e '\f'; echo $sep; fi ) >> log/checkcore.log
