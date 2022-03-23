#!/bin/bash

# Build a bootstrap version of REDUCE on Common Lisp.
# Based on "psl/bootstrap.sh".

# Author: Francis J. Wright <https://sourceforge.net/u/fjwright>
# Modified by Rainer Schöpf to support Armed Bear Common Lisp.

# Build an initial bootstrap REDUCE image without fasl files, which
# does not form part of the final REDUCE system and should not need to
# be rebuilt very often.  It is used (by build.sh) to compile REDUCE.
# Assume this script is run in the top-level CL REDUCE directory.

# Usage: ./bootstrap.sh -l sbcl/clisp/abcl

if getopts l: option; then lisp=$OPTARG; fi

if [ "$lisp" = 'sbcl' ]; then
    runlisp='sbcl'
    runlispfile='sbcl --load'
    saveext='img'
    faslext='fasl'
elif [ "$lisp" = 'clisp' ]; then
    runlisp='clisp -ansi'
    runlispfile='clisp -ansi'
    saveext='mem'
    faslext='fas'
elif [ "$lisp" = 'abcl' ]; then
    runlisp='java -jar abcl-bin-1.8.0/abcl.jar --noinit'
    runlispfile='java -jar abcl-bin-1.8.0/abcl.jar --noinit --load'
    saveext='jar'
    faslext='abcl'
else
    echo 'Error: option -l sbcl/clisp/abcl is required'
    exit 1
fi

if [ ! -v reduce ]; then
    if [ -e './packages' ]; then export reduce=.
    elif [ -e '../packages' ]; then export reduce=..
    else echo 'Error: cannot find packages directory.  Please set $reduce.'; exit 1
    fi
fi

mkdir -p log.$lisp           # -p avoids complaint if directory exists
mkdir -p fasl.$lisp

if [ "sl-on-cl.lisp" -nt "sl-on-cl.$faslext" ]
then echo +++++ Compiling sl-on-cl
$runlisp << XXX &> log.$lisp/sl-on-cl.blg
(or (compile-file "sl-on-cl") (exit #+SBCL :code 1))
XXX
fi || { echo '***** Compilation failed'; exit 1; }

echo +++++ Building bootstrap REDUCE

time $runlispfile bootstrap &> log.$lisp/bootstrap.blg

if [ ! -e fasl.$lisp/bootstrap.$saveext ]
then echo '***** Building bootstrap REDUCE failed'; exit 1;
else
echo +++++ Bootstrap REDUCE built
echo 'Possible errors:'
grep --ignore-case '\*\*\*\*\*\|\<error\>' log.$lisp/bootstrap.blg
fi

echo $'\a'
