#!/bin/bash

# Author: Francis J. Wright <https://sourceforge.net/u/fjwright>
# Time-stamp: <2026-08-01 11:23:19 franc>

#                   EXPERIMENTAL AND UNSUPPORTED!

# Build REDUCE on implementations of Common Lisp (CL) that cannot save
# a memory image, currently only ECL (and maybe ABCL later).

# Based on "psl/bootstrap.sh" and "psl/build.sh".

# Preliminary support for Armed Bear Common Lisp (ABCL) by Rainer Schöpf.

# This script assumes that the version of Common Lisp to be used has
# already been built if necessary and installed in a directory on your
# command search path.  It then does the following, where the details
# depend on the Lisp in use:

# 1. Compile "sl-on-cl.lisp", which implements Standard Lisp on Common
#    Lisp.

# 2. Build an initial bootstrap REDUCE system by using only REDUCE
#    source files.  This does not form part of the final REDUCE
#    system; it is used only to compile a full REDUCE system.

# 3. Compile "trace.lisp", which provides function tracing.

# 4. Compile all required packages and save a final REDUCE system.

# This script must be run with the top-level CL REDUCE directory
# called "common-lisp" as the current directory.

# Always do a clean build after updating your version of Common Lisp!

function help {
    echo 'Build (eXtra) REDUCE on Common Lisp (eXperimental and unsupported)'
    echo 'Usage: ./buildx.sh [-h] [-r revision] [-c/f] [-d] [-b/o] <lisp> <lisp> ...'
    # echo '<lisp> = abcl/ecl[pn]'
    echo '<lisp> = ecl[pn]'
    # echo 'If no <lisp> specified then build on ???.'
    echo 'Option -r sets the REDUCE revision number (overriding the default).'
    echo 'Option -c ensures a clean build by deleting any previous build.'
    echo 'Option -f forces recompilation of all packages.'
    echo 'Option -d configures the build for debugging.'
    echo 'Option -m use Common Lisp floating-point math functions.'
    echo 'Option -n do NOT use Common Lisp floating-point math functions.'
    echo 'Option -b builds only the bootstrap REDUCE image.'
    echo 'Option -o builds only the core REDUCE packages.'
    echo 'Option -i builds only the core packages and REDUCE image.'
    echo 'Option -h displays this help message and exits.'
    echo '(ECL: ecl[p] - Portable byte-code; ecln - Native binary code).'
    exit 1
}

while getopts r:cfdmnboih option
do
    case $option in
        r) revision=$OPTARG;;
        c) clean=true;;
        f) force='!*forcecompile := t;';;
        d) debug='(push :DEBUG *features*)';;
        m) lispmath='(push :LISPMATH *features*)';;
        n) nolispmath='(push :NOLISPMATH *features*)';;
        b) bootstraponly=true;;
        o) coreonly=true;;
        i) imageonly=true;;
        h) help;;
        ?) exit 1;;
    esac
done

shift $((--OPTIND))
lisps=$@                        # lisps=${@:-'abcl eclp ecln'}
[[ -n "$lisps" ]] || { echo $'Error: <lisp> argument is required\n'; help; }

[ -n "$debug" ] && echo '+++++ Building for debugging'
[ -n "$lispmath" ] && echo '+++++ Using Common Lisp floating-point math functions'
[ -n "$nolispmath" ] && echo '+++++ NOT using Common Lisp floating-point math functions'

if [ -z "$reduce" ]
then
    if [ -e './packages' ]; then export reduce=.
    elif [ -e '../packages' ]; then export reduce=..
    else echo 'Error: cannot find packages directory.  Please set $reduce.'; exit 1
    fi
fi

if [ -z "$revision" ]
then
    if type svnversion > /dev/null
    then
        # Try to use Subversion in the packages directory:
        packages="$reduce/packages"
        # If $packages is a symlink then follow it (if possible):
        if [ -L $packages ] && type readlink > /dev/null
        then
            packages=$(readlink -n "$packages")
        fi
        revision=$(svnversion -n "$packages")
        # Value may be (e.g.) 4123:4168MSP so extract the second number:
        revision=${revision/#*:}     # delete first number and ":"
        revision=${revision/%[A-Z]*} # delete trailing letters
    fi
    if [[ ! "$revision" =~ ^[[:digit:]]+$ ]]
    then
        # Try to parse the parent directory name:
        revision=$(basename $(realpath ..))
        shopt -s extglob
        revision=${revision/#+([^[:digit:]])} # delete leading non-digits
        revision=${revision/%+([^[:digit:]])} # delete trailing non-digits
        shopt -u extglob
    fi
fi
if [[ "$revision" =~ ^[[:digit:]]+$ ]]
then
    echo '+++++ REDUCE revision number set to' $revision
else
    echo '*** The REDUCE revision number cannot be set automatically.'
    echo '    You can use the -r option to set it manually.'
    unset -v revision
fi

for lisp in $lisps
do
    lisp=${lisp,,}              # ensure lower case

    # The following commands to run Lisp and REDUCE all suppress the
    # Lisp and REDUCE user initialisation files.  (Note that Bootstrap
    # REDUCE never reads the init file.)

    case $lisp in
        # 'abcl')
        #     echo $'\n========================================='
        #     echo    'Building REDUCE on Armed Bear Common Lisp'
        #     echo   $'=========================================\n'
        #     runlisp='java -jar abcl-bin-1.8.0/abcl.jar --noinit'
        #     runlispfile='java -jar abcl-bin-1.8.0/abcl.jar --noinit --load'
        #     runbootstrap='java -jar abcl-bin-1.8.0/abcl.jar --noinit --noinform -M fasl.abcl/bootstrap.mem'
        #     runreduce='java -jar abcl-bin-1.8.0/abcl.jar --noinit --noinform -M fasl.abcl/reduce.mem'
        #     saveext='jar'
        #     faslext='abcl';;
        'ecl')
            # Use portable byte-code FASL files by default.
            # macOS bash may not support the following ;& syntax, so I may
            # need to merge these two cases into:
            # 'ecl' | 'eclp') lisp='eclp';...
            lisp='eclp';&       # fall through
        'eclp')
            echo $'\n========================================='
            echo    'Building REDUCE on Embeddable Common Lisp'
            echo    'using portable byte-code FASL files'
            echo   $'=========================================\n'
            runlisp='ecl --norc --eval "(pushnew :ECLP *features*)"'
            runlispfile="$runlisp --load"
            runbootstrap="$runlisp --load fasl.eclp/bootstrapreduce"
            runreduce='./redeclp --no-rcfile'
            faslext='fasc';;
        'ecln')
            echo $'\n========================================='
            echo    'Building REDUCE on Embeddable Common Lisp'
            echo    'using (default) native binary FASL files'
            echo   $'=========================================\n'
            runlisp='ecl --norc --eval "(pushnew :ECLN *features*)"'
            runlispfile="$runlisp --load"
            runbootstrap="$runlisp --load fasl.ecln/bootstrapreduce"
            runreduce='./redecln --no-rcfile'
            faslext='fas';;
        *)
            echo $'Error: invalid <lisp> argument\n'
            help
            ;;
    esac

    date="$(date +%d-%b-%Y)"
    lispversion="`ecl --version | sed '1s/^\([^0-9.]\+[0-9.]\+\).*/\1/;q'`"

    if [ -n "$clean" ]
    then
        echo '+++++ Clean build'
        rm -rf fasl.$lisp log.$lisp
    fi

    mkdir -p log.$lisp       # -p avoids complaint if directory exists
    mkdir -p fasl.$lisp

    #################################
    # Compile sl-on-cl if necessary #
    #################################

    if [ "sl-on-cl.lisp" -nt "fasl.$lisp/sl-on-cl.$faslext" ]
    then
        echo $'\n+++++ Compiling sl-on-cl'
        time eval $runlisp << EOF &> log.$lisp/sl-on-cl.blg &&
$debug $lispmath $nolispmath
#+ECLP (ext:install-bytecodes-compiler)
(or (compile-file "sl-on-cl.lisp")
    #+ECL (quit 1))
EOF
        mv sl-on-cl.$faslext fasl.$lisp
    fi || { echo '***** Compilation failed'; exit 1; }

    #####################################
    # Build an initial bootstrap REDUCE #
    #####################################

    function grep_errors {
        grep -i '^\*\{5\} \| error \|COMMON-LISP:ERROR' log.$lisp/$1.blg | uniq |\
            grep -viw errorset  # except matching lines
    }

    echo $'\n+++++ Building' ${lisp@U} 'bootstrap REDUCE...'
    time eval $runlispfile bootstrap << EOF &> log.$lisp/bootstrap.blg
% Compile fasl files for the minimal set of packages:
symbolic; $force
off redefmsg;
package!-remake2('clprolo, nil);
package!-remake 'rlisp;
package!-remake2('smacros,'support);
package!-remake2('clrend, nil);
package!-remake 'poly;
package!-remake 'alg;
package!-remake 'rtools;
package!-remake 'arith;
package!-remake2('entry, 'support);
package!-remake2('remake, nil);
bye;
EOF
    echo $'\n+++++ Building' ${lisp@U} 'bootstrap REDUCE done.  Possible errors:'
    grep_errors bootstrap

    if [ -n "$bootstraponly" ]
    then
        echo $'\nBootstrap only build requested.'
        continue
    fi

    echo $'\n+++++ Building the' ${lisp@U} 'bootstrap REDUCE dynamic load file...'

    # Can't currently build REDUCE the conventional way,
    # i.e. statically!  Instead, build
    # "fasl.ecl/bootstrapreduce.lisp", which builds bootstrap REDUCE
    # dynamically.

    sed -e 's/[;%].*// ; /^ *$/d' \
        -e "s/@date/$date/;s/@revision/$revision/;s/@lispversion/$lispversion/" \
        bootstrapreduce-ecl.lisp > fasl.$lisp/bootstrapreduce.lisp

    echo "+++++ Built the ${lisp@U} bootstrap REDUCE dynamic load file."

    ################
    # Build REDUCE #
    ################

    echo -n $'\n+++++ Collecting package data...'

    eval $runbootstrap << EOF &> log.$lisp/build.blg
symbolic; $force

off redefmsg;

% First, compile fasl files for non-package source files:

package!-remake2('clprolo, nil);
package!-remake2('clrend, nil);
package!-remake2('entry, 'support);
package!-remake2('smacros,'support);
package!-remake2('remake, nil); % for building noncore packages

% Second, create .dat files that list core and non-core modules to build:

begin
   scalar w, i, s, core, noncore;
   i := open("$reduce/packages/package.map", 'input);
   s := rds i;
   w := read();
   rds s;
   close i;
   for each x in w do     % x is a row of package.map
      if member('csl, x) and member('psl, x) then <<
         if member('core, x) then
            << if not (car x eq 'revision) then
               core := car x . core >>
         else noncore := car x . noncore >>;
   i := open("fasl.$lisp/core-packages.dat", 'output);
   s := wrs i;
   for each x in reverse core do print x;
   wrs s;
   close i;
   i := open("fasl.$lisp/noncore-packages.dat", 'output);
   s := wrs i;
   for each x in reverse noncore do print x;
   wrs s;
   close i;
end;

bye;
EOF

    if [ ! -e fasl.$lisp/core-packages.dat -o ! -e fasl.$lisp/noncore-packages.dat ]
    then
        echo 'failed'; exit 1
    else
        echo 'done.  Possible errors:'
        grep_errors build
    fi

    echo $'\n+++++ Building REDUCE...'

    # Compile the "core" packages, each in a separate invocation of
    # bootstrap REDUCE to avoid adverse interactions:

    time \
        { for p in $(< fasl.$lisp/core-packages.dat)
          do
              echo "+++++ Remaking core package $p"
              eval $runbootstrap << EOF &> log.$lisp/$p.blg
symbolic; $force

off redefmsg;

begin
   scalar w, i, s;
   i := open("$reduce/packages/package.map", 'input);
   s := rds i;
   w := read();
   rds s;
   close i;
   for each x in w do put(car x, 'folder, cadr x)
end;

package!-remake '$p;

bye;
EOF

              grep_errors $p

          done; }         # for p in $(< fasl.$lisp/core-packages.dat)

    if [ -n "$coreonly" ]
    then
        echo $'\nCore packages only build requested.'
        continue
    fi

    ##############################
    # Compile trace if necessary #
    ##############################

    if [ "trace.lisp" -nt "fasl.$lisp/trace.$faslext" ]
    then
        echo $'\n+++++ Compiling trace'
        time eval $runlisp << EOF &> log.$lisp/trace.blg &&
(load "fasl.$lisp/sl-on-cl")
(or (compile-file "trace.lisp") (exit 1))
EOF
        mv trace.$faslext fasl.$lisp
    fi || { echo '***** Compiling trace failed'; exit 1; }

    ######################
    # Build REDUCE files #
    ######################

    # Can't currently build REDUCE the conventional way,
    # i.e. statically!  Instead, build "fasl.ecl/reduce.lisp", which
    # builds REDUCE dynamically.

    echo $'\n+++++ Building the' ${lisp@U} 'REDUCE dynamic load file...'

    sed -e 's/[;%].*// ; /^ *$/d' \
        -e "s/@date/$date/;s/@revision/$revision/;s/@lispversion/$lispversion/" \
        reduce-ecl.lisp > fasl.$lisp/reduce.lisp

    echo '+++++ Built the' ${lisp@U} $'REDUCE dynamic load file.\n'

    if [ -n "$imageonly" ]
    then
        echo 'Core packages and REDUCE "image" only build requested.'
        continue
    fi

    # Finally, compile the "noncore" packages using full REDUCE rather
    # than the bootstrap version.

    time \
        { for p in $(< fasl.$lisp/noncore-packages.dat)
          do
              echo "+++++ Remaking noncore package $p"
              eval $runreduce << EOF &> log.$lisp/$p.blg
symbolic; $force

on verboseload;
off redefmsg;

if '$p eq 'fps then load_package limits,factor,specfn,sfgamma
else if '$p eq 'mrvlimit then load_package taylor
% Temporary hacks to avoid build errors:
else if '$p eq 'corrundum then
   << if 'ecl memq lispsystem!* then bye else flag('(flush),'rlisp) >>
else if '$p eq 'tmprint then <<
   lispsystem!* := 'psl . lispsystem!*;
   switch usermode >>;

!*argnochk := t;

begin
   scalar w, i, s;
   i := open("$reduce/packages/package.map", 'input);
   s := rds i;
   w := read();
   rds s;
   close i;
   for each x in w do put(car x, 'folder, cadr x)
end;

package!-remake '$p; % autoloads remake

% Temporary hack to make gnuplot package work on Common Lisp:
if '$p eq 'gnuplot then
   begin scalar !*int, !*forcecompile := t;
      update!-fasl2('gnuintfc, nil);
   end;

bye;
EOF

              grep_errors $p

          done; }      # for p in $(< fasl.$lisp/noncore-packages.dat)

    echo $'\n+++++ Built REDUCE.'

done                            # for lisp in $lisps
